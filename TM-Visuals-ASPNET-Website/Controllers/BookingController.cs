using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Globalization;
using System.Security.Claims;
using System.Text.Json;
using TMVisualsWebApp.Models;
using TMVisualsWebApp.Services;

namespace TMVisualsWebApp.Controllers
{
    public class BookingController : Controller
    {
        // South Africa is UTC+2 year-round, with no daylight saving.
        private static readonly TimeSpan SastOffset = TimeSpan.FromHours(2);
        // A booking must cover at least this much time.
        private static readonly TimeSpan MinimumDuration = TimeSpan.FromHours(1);
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<BookingController> _logger;
        private readonly SupabaseDataService _data;
        private readonly SupabaseSessionService _session;
        private readonly ServicesCatalogService _servicesCatalog;

        public BookingController(
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<BookingController> logger,
            SupabaseDataService data,
            SupabaseSessionService session, 
            ServicesCatalogService servicesCatalog)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
            _data = data;
            _servicesCatalog = servicesCatalog;
            _session = session;
        }

        // Availability must always be fresh, so it never let a browser or proxy cache it.
        // The calendar reads the database's time slots (get_booking_calendar).
        [Authorize]
        [HttpGet]
        [ResponseCache(NoStore = true, Location = ResponseCacheLocation.None)]
        public async Task<IActionResult> Availability(
            int year,
            int month,
            CancellationToken cancellationToken)
        {
            if (year < 2000 || year > 2100 || month < 1 || month > 12)
            {
                return BadRequest();
            }

            // The database only lets signed-in users read the calendar.
            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Unauthorized();
            }

            var first = new DateOnly(year, month, 1);
            var last = first.AddMonths(1).AddDays(-1);

            try
            {
                var slots = await _data.GetCalendarAsync(
                    accessToken, first, last, cancellationToken);
                return Json(new { days = BookingCalendar.BuildMonth(year, month, slots) });
            }
            catch (Exception error) when (
     error is HttpRequestException or
     SupabaseDataException or
     JsonException or
     InvalidOperationException or
     KeyNotFoundException or
     FormatException)
            {
                _logger.LogError(error, "Could not load booking availability.");
                return StatusCode(StatusCodes.Status503ServiceUnavailable);
            }
        }




        //might be deleted 
        private async Task<List<string>> LoadServicesAsync(
    CancellationToken cancellationToken)
        {
            try
            {
                var services = await _servicesCatalog.FetchActiveServiceNamesAsync(
                    cancellationToken);

                ViewBag.Services = services;
                return services;
            }
            catch (Exception error) when (
                error is HttpRequestException or
                JsonException or
                InvalidOperationException)
            {
                _logger.LogError(error, "Could not load active booking services.");

                ViewBag.Services = new List<string>();
                return new List<string>();
            }
        }

        [Authorize]
        [HttpGet]
        public async Task<IActionResult> CreateBooking(
     CancellationToken cancellationToken)
        {
            TempData.Remove("BookingConfirmation");

            await LoadServicesAsync(cancellationToken);

            return View(new Booking
            {
                Email = User.FindFirstValue(ClaimTypes.Email) ?? string.Empty
            });
        }

        [Authorize]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CreateBooking(
            [Bind(
                nameof(Booking.Name),
                nameof(Booking.Phone),
                nameof(Booking.Email),
                nameof(Booking.Service),
                nameof(Booking.EventType),
                nameof(Booking.Date),
                nameof(Booking.StartTime),
                nameof(Booking.FinishTime),
                nameof(Booking.Location),
                //nameof(Booking.requirements),
                nameof(Booking.Latitude),
                nameof(Booking.Longitude),
                nameof(Booking.NumberOfPeople),
                nameof(Booking.Budget),
                nameof(Booking.AcceptTerms))]
            Booking booking,
            CancellationToken cancellationToken)
        {
            // Use the logged-in user's email so the booking shows on their Profile
            booking.Email = User.FindFirstValue(ClaimTypes.Email) ?? string.Empty;
            ModelState.Remove(nameof(Booking.Email));
            var activeServices = await LoadServicesAsync(cancellationToken);
            NormalizeBooking(booking);
            ValidateBooking(booking, activeServices);

            if (!ModelState.IsValid)
            {
                foreach (var entry in ModelState.Where(x => x.Value!.Errors.Count > 0))
                {
                    foreach (var error in entry.Value!.Errors)
                    {
                        // The posted value is deliberately not logged: it can be a
                        // name, phone number or email address.
                        _logger.LogWarning(
                            "Booking validation error on '{Field}': {Error}",
                            entry.Key,
                            error.ErrorMessage);
                    }
                }

                return View(booking);
            }

            if (!Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var userId))
            {
                return Forbid();
            }

            // The database books on behalf of the signed-in user, so it needs their
            // Supabase token. A missing token means they signed in before tokens
            // were stored, or the session expired: sign in again.
            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            // The status is set by the server, not accepted from the form.
            booking.Status = "Pending";
            booking.UserId = userId;

            try
            {
                var day = DateOnly.FromDateTime(booking.Date!.Value);
                var daySlots = await _data.GetCalendarAsync(
                    accessToken, day, day, cancellationToken);

                var chosen = BookingCalendar.Cover(
                    daySlots,
                    booking.StartTime!.Value,
                    booking.FinishTime!.Value);

                if (chosen is null)
                {
                    var example = daySlots.FirstOrDefault(slot => slot.Available);
                    ModelState.AddModelError(
                        nameof(Booking.Date),
                        example is null
                            ? "There are no available times on that date. Please choose another date."
                            : "Choose start and finish times that line up with the available " +
                              $"slots, for example {BookingCalendar.Format(example.Start)} to " +
                              $"{BookingCalendar.Format(example.End)}.");

                    return View(booking);
                }

                if (chosen.Any(slot => !slot.Available))
                {
                    ModelState.AddModelError(
                        nameof(Booking.Date),
                        "That time is no longer available. " +
                        "Please choose another time or date.");

                    return View(booking);
                }

                var serviceIds = await _data.ResolveServiceIdsAsync(
                    accessToken,
                    booking.Service,
                    cancellationToken);

                // The database stores contact details on the user's profile, not
                // on the booking, so keep what was typed on the form in the
                // booking's requirements where the photographer can see it.
                //var requirements =
                //  $"Contact name: {booking.Name}\nContact phone: {booking.Phone}";
                var requirements = string.IsNullOrWhiteSpace(booking.Requirements)
  ? null
  : booking.Requirements.Trim();

                booking.Id = await _data.CreateBookingAsync(
                    accessToken,
                    new BookingRequest(
                        chosen.Select(slot => slot.Id).ToList(),
                        serviceIds,
                        booking.EventType,
                        booking.Budget,
                        requirements,
                        booking.NumberOfPeople,
                        booking.Location,
                        booking.AcceptTerms,
                        booking.Latitude,
                        booking.Longitude),
                    cancellationToken);
            }
            catch (SupabaseDataException error) when (error.StatusCode is >= 400 and < 500)
            {
                _logger.LogWarning(
                    "Booking rejected by the database: HTTP {Status}, {Message}",
                    error.StatusCode,
                    error.Message);

                ModelState.AddModelError(nameof(Booking.Date), FriendlyBookingError(error.Message));
                return View(booking);
            }
            catch (Exception error) when (
     error is HttpRequestException or
     SupabaseDataException or
     JsonException or
     InvalidOperationException or
     KeyNotFoundException or
     FormatException)
            {
                _logger.LogError(error, "The booking could not be saved.");

                ModelState.AddModelError(
                    nameof(Booking.Date),
                    "We couldn't save your booking right now. Please try again in a moment.");
                return View(booking);
            }

            booking.ExpiresAtUtc = DateTimeOffset.UtcNow.AddHours(1);

            TempData["BookingConfirmation"] =
                JsonSerializer.Serialize(BuildConfirmation(booking));

            return RedirectToAction(nameof(Confirmation));
        }

        [Authorize]
        [HttpGet]
        public IActionResult Confirmation()
        {
            // Peek so refreshing the page doesn't immediately remove the confirmation.
            var json = TempData.Peek("BookingConfirmation") as string;

            if (string.IsNullOrEmpty(json))
            {
                return RedirectToAction(nameof(CreateBooking));
            }

            var model =
                JsonSerializer.Deserialize<BookingConfirmationViewModel>(json);

            if (model is null)
            {
                return RedirectToAction(nameof(CreateBooking));
            }

            return View(model);
        }

        // Turns the database's error text into something a customer can act on.
        private static string FriendlyBookingError(string message)
        {
            if (message.Contains("claimed", StringComparison.OrdinalIgnoreCase) ||
                message.Contains("unavailable", StringComparison.OrdinalIgnoreCase) ||
                message.Contains("active reservation", StringComparison.OrdinalIgnoreCase) ||
                message.Contains("missing", StringComparison.OrdinalIgnoreCase))
            {
                return "That time is no longer available. " +
                       "Please choose another time or date.";
            }

            if (message.Contains("Client profile not found", StringComparison.OrdinalIgnoreCase))
            {
                return "Your account isn't set up for bookings yet. " +
                       "Please contact us so we can fix this.";
            }

            if (message.Contains("Authentication", StringComparison.OrdinalIgnoreCase) ||
                message.Contains("JWT", StringComparison.OrdinalIgnoreCase))
            {
                return "Your session has expired. Please sign out and sign in again.";
            }

            if (message.Contains("not available right now", StringComparison.OrdinalIgnoreCase))
            {
                return message;
            }

            return "We couldn't save your booking. Please check the details and try again.";
        }

        private BookingConfirmationViewModel BuildConfirmation(Booking booking)
        {
            var typeOfBooking = $"{booking.EventType} - {booking.Service}";
            var reference = booking.Id.ToString("N")[..8].ToUpperInvariant();

            var message = string.Join(
                "\n",
                "Hi, I've just submitted a booking and I'd like to discuss the details and pricing.",
                "[Details]",
                $"Booking ref: #{reference}",
                $"Name: {booking.Name}",
                $"Type of booking: {typeOfBooking}",
                $"Date: {booking.Date:yyyy-MM-dd}",
                $"Budget: R{booking.Budget:N2}",
                $"Email: {booking.Email}",
                $"Contact number: {booking.Phone}",
                $"Location: {booking.Location}",
                $"Number of people: {booking.NumberOfPeople}",
                $"Start time: {booking.StartTime:hh\\:mm}",
                $"Finish time: {booking.FinishTime:hh\\:mm}"
                );

            // Strips out all non-digit characters from the WhatsApp number, so that it can be used in a wa.me link.
            var number = new string(
                (_configuration["WhatsApp:BusinessNumber"] ?? string.Empty)
                    .Where(char.IsDigit)
                    .ToArray());

            var whatsAppUrl = string.Empty;

            if (number.Length < 8)
            {
                _logger.LogWarning(
                    "WhatsApp:BusinessNumber is missing or invalid; WhatsApp link not generated.");
            }
            else
            {
                whatsAppUrl =
                    $"https://wa.me/{number}?text={Uri.EscapeDataString(message)}";
            }

            return new BookingConfirmationViewModel
            {
                BookingId = booking.Id,
                Name = booking.Name,
                Email = booking.Email,
                Phone = booking.Phone,
                Service = booking.Service,
                EventType = booking.EventType,
                Date = booking.Date,
                StartTime = booking.StartTime,
                FinishTime = booking.FinishTime,
                Location = booking.Location,
                Budget = booking.Budget,
                NumberOfPeople = booking.NumberOfPeople,
                WhatsAppUrl = whatsAppUrl,
                Status = booking.Status
            };
        }

        [HttpGet("/Booking/SearchLocations")]
        public async Task<IActionResult> SearchLocations(
            string? query,
            double? latitude,
            double? longitude,
            CancellationToken ct)
        {
            query = query?.Trim();

            if (string.IsNullOrWhiteSpace(query) || query.Length < 3)
            {
                return Json(Array.Empty<object>());
            }

            var url =
                $"api?q={Uri.EscapeDataString(query)}" +
                "&limit=8" +
                "&lang=en";

            if (latitude.HasValue && longitude.HasValue)
            {
                url += $"&lat={latitude.Value.ToString(CultureInfo.InvariantCulture)}" +
                       $"&lon={longitude.Value.ToString(CultureInfo.InvariantCulture)}";
            }

            // Rough South Africa bounding box: minLon,minLat,maxLon,maxLat. Th
            url += "&bbox=16.3,-35.0,33.1,-22.0";

            try
            {
                using var doc = await GetPhotonAsync(url, ct);

                if (!doc.RootElement.TryGetProperty("features", out var features) ||
                    features.ValueKind != JsonValueKind.Array)
                {
                    return Json(Array.Empty<object>());
                }

                var results = new List<object>();
                var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                foreach (var feature in features.EnumerateArray())
                {
                    if (!feature.TryGetProperty("properties", out var properties))
                    {
                        continue;
                    }

                    if (!feature.TryGetProperty("geometry", out var geometry) ||
                        !geometry.TryGetProperty("coordinates", out var coordinates) ||
                        coordinates.ValueKind != JsonValueKind.Array ||
                        coordinates.GetArrayLength() < 2)
                    {
                        continue;
                    }

                    var label = BuildLabel(properties);

                    if (string.IsNullOrWhiteSpace(label) || !seen.Add(label))
                    {
                        continue;
                    }

                    if (!coordinates[0].TryGetDouble(out var longitudeResult) ||
                        !coordinates[1].TryGetDouble(out var latitudeResult))
                    {
                        continue;
                    }

                    results.Add(new
                    {
                        displayName = label,
                        latitude = latitudeResult,
                        longitude = longitudeResult
                    });

                    if (results.Count == 5)
                    {
                        break;
                    }
                }

                return Json(results);
            }
            catch (OperationCanceledException) when (ct.IsCancellationRequested)
            {
                return StatusCode(499);
            }
            catch (Exception)
            {
                //KamoheloP: This may be a potentially sensitive log, so it is commented out for now.
                //If you want to log the error, make sure to sanitize the query parameter to avoid logging sensitive information.
                /* _logger.LogError(
                     ex,
                     "Location search failed for query '{Query}'.",
                     query);*/

                return StatusCode(StatusCodes.Status502BadGateway);
            }
        }

        [HttpGet("/Booking/ReverseGeocode")]
        public async Task<IActionResult> ReverseGeocode(
            double latitude, double longitude, CancellationToken ct)
        {
            /*if (latitude is < -90 or > 90 ||
                longitude is < -180 or > 180 ||
                (latitude == 0 && longitude == 0))
            {
                return BadRequest(
               */ //Scheduled to be removed if CoordinatePairAttribute works

            var url =
                $"reverse?lat={latitude.ToString(CultureInfo.InvariantCulture)}" +
                $"&lon={longitude.ToString(CultureInfo.InvariantCulture)}" +
                "&limit=1&lang=en";

            try
            {
                using var doc = await GetPhotonAsync(url, ct);

                if (!doc.RootElement.TryGetProperty("features", out var features) ||
                    features.ValueKind != JsonValueKind.Array ||
                    features.GetArrayLength() == 0)
                {
                    return NotFound(new { message = "No address was found." });
                }

                if (!features[0].TryGetProperty("properties", out var properties))
                {
                    return NotFound(
                        new { message = "No readable address was found." });
                }

                var label = BuildLabel(properties);

                if (string.IsNullOrWhiteSpace(label))
                {
                    return NotFound(
                        new { message = "No readable address was found." });
                }

                return Json(new
                {
                    displayName = label,
                    latitude,
                    longitude
                });
            }
            catch (OperationCanceledException) when (ct.IsCancellationRequested)
            {
                return StatusCode(499);
            }
            catch (Exception ex) when (
                ex is HttpRequestException or
                      JsonException or
                      OperationCanceledException)
            {
                //KamoheloP:Again, this may be a potentially sensitive log, so it is commented out for now.
                /*
                _logger.LogError(
                    ex,
                    "Reverse geocode failed for {Lat},{Lon}.",
                    latitude,
                    longitude);*/

                return StatusCode(
                    StatusCodes.Status502BadGateway,
                    new { message = "The location service is unavailable." });
            }
        }

        private async Task<JsonDocument> GetPhotonAsync(
            string url, CancellationToken ct)
        {
            var client = _httpClientFactory.CreateClient("photon");

            using var response = await client.GetAsync(url, ct);
            response.EnsureSuccessStatusCode();

            await using var stream =
                await response.Content.ReadAsStreamAsync(ct);

            return await JsonDocument.ParseAsync(
                stream,
                cancellationToken: ct);
        }

        private static string BuildLabel(JsonElement properties)
        {
            string? Get(string key) =>
                properties.TryGetProperty(key, out var value) &&
                value.ValueKind == JsonValueKind.String
                    ? value.GetString()
                    : null;

            var street = Get("street");
            var houseNumber = Get("housenumber");
            var streetLine = street is null
                ? null
                : houseNumber is null
                    ? street
                    : $"{houseNumber} {street}";

            var parts = new[]
            {
                Get("name"),
                streetLine,
                Get("district") ?? Get("locality"),
                Get("city"),
                Get("state"),
                Get("postcode"),
                Get("country")
            }
            .Where(value => !string.IsNullOrWhiteSpace(value))
            .Distinct(StringComparer.OrdinalIgnoreCase);

            return string.Join(", ", parts);
        }
        // Model binding turns empty fields into null, so be null-safe here.
        private static void NormalizeBooking(Booking booking)
        {
            booking.Name = booking.Name?.Trim() ?? string.Empty;
            booking.Phone = booking.Phone?.Trim() ?? string.Empty;
            booking.Email = booking.Email?.Trim() ?? string.Empty;
            booking.Location = booking.Location?.Trim() ?? string.Empty;
        }

        // ValidateBooking checks the Booking object for additional validation rules that are not covered by data annotations.
        private void ValidateBooking(Booking booking, List<string> activeServices)
        {
            // AcceptTerms is validated by the MustBeTrue attribute on Booking.

            if (activeServices.Count == 0)
            {
                ModelState.AddModelError(
                    nameof(booking.Service),
                    "Services are currently unavailable. Please try again later.");
            }
            else if (!string.IsNullOrWhiteSpace(booking.Service) &&
                     !activeServices.Contains(
                         booking.Service,
                         StringComparer.OrdinalIgnoreCase))
            {
                ModelState.AddModelError(
                    nameof(booking.Service),
                    "Please select a valid service.");
            }

            if (!string.IsNullOrWhiteSpace(booking.EventType) &&
                !BookingOptions.EventTypes.Contains(booking.EventType))
            {
                ModelState.AddModelError(
                    nameof(booking.EventType),
                    "Please select a valid event type.");
            }

            // [Phone] is very loose (it accepts almost anything with a digit),
            // so also require a realistic number of digits.
            var phoneDigits = booking.Phone?.Count(char.IsDigit) ?? 0;

            if (!string.IsNullOrWhiteSpace(booking.Phone) && phoneDigits is < 9 or > 15)
            {
                ModelState.AddModelError(
                    nameof(booking.Phone),
                    "Please enter a valid phone number (9 to 15 digits).");
            }

            // South Africa is UTC+2 year-round. This is used to check that the booking date/time is not in the past.
            var nowSast = DateTimeOffset.UtcNow.ToOffset(SastOffset);

            if (booking.Date.HasValue)
            {
                var bookingDate = booking.Date.Value.Date;

                if (bookingDate < nowSast.Date)
                {
                    ModelState.AddModelError(
                        nameof(booking.Date),
                        "The booking date cannot be in the past.");
                }
                else if (bookingDate == nowSast.Date &&
                         booking.StartTime.HasValue &&
                         booking.StartTime.Value <= nowSast.TimeOfDay)
                {
                    ModelState.AddModelError(
                        nameof(booking.StartTime),
                        "The start time has already passed today.");
                }
            }

            if (booking.StartTime.HasValue && booking.FinishTime.HasValue)
            {
                var duration = booking.FinishTime.Value - booking.StartTime.Value;

                if (duration <= TimeSpan.Zero)
                {
                    ModelState.AddModelError(
                        nameof(booking.FinishTime),
                        "The finish time must be later than the start time.");
                }
                else if (duration < MinimumDuration)
                {
                    ModelState.AddModelError(
                        nameof(booking.FinishTime),
                        "Bookings must be at least 1 hour long.");
                }
            }
        }
    }
}
