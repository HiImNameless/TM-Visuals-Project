using Microsoft.AspNetCore.Mvc;
using System.Globalization;
using System.Text.Json;
using TMVisualsWebApp.Models;

namespace TMVisualsWebApp.Controllers
{
    public class BookingController : Controller
    {
        // South Africa is UTC+2 year-round (no daylight saving), so a fixed offset
        // avoids Windows/Linux time zone ID differences.
        private static readonly TimeSpan SastOffset = TimeSpan.FromHours(2);

        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<BookingController> _logger;

        public BookingController(
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<BookingController> logger)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
        }

        public IActionResult CreateBooking()
        {
            return View(new Booking());
        }

        // [Bind] whitelist: Id and Status can never be set by the client.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult CreateBooking(
            [Bind(nameof(Booking.Name),
                  nameof(Booking.Phone),
                  nameof(Booking.Email),
                  nameof(Booking.Service),
                  nameof(Booking.EventType),
                  nameof(Booking.Date),
                  nameof(Booking.StartTime),
                  nameof(Booking.FinishTime),
                  nameof(Booking.Location),
                  nameof(Booking.Latitude),
                  nameof(Booking.Longitude),
                  nameof(Booking.NumberOfPeople),
                  nameof(Booking.Budget),
                  nameof(Booking.AcceptTerms))]
            Booking booking)
        {
            ValidateBooking(booking);

            if (!ModelState.IsValid)
            {
                foreach (var entry in ModelState.Where(x => x.Value!.Errors.Count > 0))
                {
                    foreach (var error in entry.Value!.Errors)
                    {
                        _logger.LogWarning(
                            "Booking validation error on '{Field}': {Error} (posted value: '{Value}')",
                            entry.Key,
                            error.ErrorMessage,
                            entry.Value.AttemptedValue);
                    }
                }

                return View(booking);
            }

            booking.Status = "Pending";

            // TODO: persist the booking (DbContext) and/or email it to yourself here.
            // Right now it is only used to build the confirmation screen.

            TempData["BookingConfirmation"] =
                JsonSerializer.Serialize(BuildConfirmation(booking));

            return RedirectToAction(nameof(Confirmation));
        }

        
         //The confirmation screen is shown after a successful booking submission.
         //It is not a "thank you" page, but rather a summary of the booking details
         //and a link to contact you (e.g. via WhatsApp) to discuss the booking.
         
        [HttpGet]
        public IActionResult Confirmation()
        {
            // Peek (not read) so a browser refresh doesn't lose the screen.
            var json = TempData.Peek("BookingConfirmation") as string;

            if (string.IsNullOrEmpty(json))
            {
                return RedirectToAction(nameof(CreateBooking));
            }

            var model = JsonSerializer.Deserialize<BookingConfirmationViewModel>(json);

            if (model is null)
            {
                return RedirectToAction(nameof(CreateBooking));
            }

            return View(model);
        }

        private BookingConfirmationViewModel BuildConfirmation(Booking booking)
        {
            var typeOfBooking = $"{booking.EventType} - {booking.Service}";

            var message = string.Join("\n",
                "Hi, I've just submitted a booking and I'd like to discuss the details and pricing.",
                "[Details]",
                $"Name: {booking.Name}",
                $"Type of booking: {typeOfBooking}",
                $"Date: {booking.Date:yyyy-MM-dd}",
                $"Budget: R{booking.Budget:N2}",
                $"Email: {booking.Email}",
                $"Contact number: {booking.Phone}");

            var number = new string(
                (_configuration["WhatsApp:Number"] ?? string.Empty)
                    .Where(char.IsDigit)
                    .ToArray());

            string whatsAppUrl = string.Empty;

            if (number.Length == 0)
            {
                // Without a number the wa.me link is broken, so leave it empty.
                // Make the Confirmation view hide the WhatsApp button when this is empty.
                _logger.LogWarning("WhatsApp:Number is not configured; WhatsApp link not generated.");
            }
            else
            {
                whatsAppUrl = $"https://wa.me/{number}?text={Uri.EscapeDataString(message)}";
            }

            return new BookingConfirmationViewModel
            {
                //Message = message,
                //WhatsAppUrl = whatsAppUrl
            };
        }
        


        [HttpGet("/Booking/SearchLocations")]
        public async Task<IActionResult> SearchLocations(
            string? query, double? latitude, double? longitude, CancellationToken ct)
        {
            query = query?.Trim();

            if (string.IsNullOrWhiteSpace(query) || query.Length < 3)
            {
                return Json(Array.Empty<object>());
            }

            // Photon has no "countrycode" parameter, so the bbox below does the restricting.
            var url =
                $"api?q={Uri.EscapeDataString(query)}" +
                "&limit=8" +
                "&lang=en";

            if (latitude.HasValue && longitude.HasValue)
            {
                url += $"&lat={latitude.Value.ToString(CultureInfo.InvariantCulture)}" +
                       $"&lon={longitude.Value.ToString(CultureInfo.InvariantCulture)}";
            }

            // Rough South Africa bounding box (minLon,minLat,maxLon,maxLat).
            // It also covers slivers of neighbouring countries.
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
            // Only treat it as "client cancelled" when the request itself was aborted.
            catch (OperationCanceledException) when (ct.IsCancellationRequested)
            {
                return StatusCode(499);
            }
            // Covers HTTP failures, bad JSON and HttpClient timeouts.
            catch (Exception ex)
            {
                _logger.LogError(ex, "Location search failed for query '{Query}'.", query);
                return StatusCode(StatusCodes.Status502BadGateway);
            }
        }

        [HttpGet("/Booking/ReverseGeocode")]
        public async Task<IActionResult> ReverseGeocode(
            double latitude, double longitude, CancellationToken ct)
        {
            if (latitude is < -90 or > 90 ||
                longitude is < -180 or > 180 ||
                (latitude == 0 && longitude == 0))
            {
                return BadRequest(new { message = "The supplied coordinates are invalid." });
            }

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
                    return NotFound(new { message = "No readable address was found." });
                }

                var label = BuildLabel(properties);

                if (string.IsNullOrWhiteSpace(label))
                {
                    return NotFound(new { message = "No readable address was found." });
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
                ex is HttpRequestException or JsonException or OperationCanceledException)
            {
                _logger.LogError(ex, "Reverse geocode failed for {Lat},{Lon}.", latitude, longitude);
                return StatusCode(
                    StatusCodes.Status502BadGateway,
                    new { message = "The location service is unavailable." });
            }
        }

        private async Task<JsonDocument> GetPhotonAsync(string url, CancellationToken ct)
        {
            // Make sure the "photon" client in Program.cs sets BaseAddress, Timeout
            // and a User-Agent header (public Photon instances expect one).
            var client = _httpClientFactory.CreateClient("photon");
            using var res = await client.GetAsync(url, ct);
            res.EnsureSuccessStatusCode();
            await using var stream = await res.Content.ReadAsStreamAsync(ct);
            return await JsonDocument.ParseAsync(stream, cancellationToken: ct);
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
            var streetLine = street is null ? null
                           : houseNumber is null ? street
                           : $"{houseNumber} {street}"; // SA style: number first

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
            .Distinct(StringComparer.OrdinalIgnoreCase); // drops "Bloemfontein, Bloemfontein"

            return string.Join(", ", parts);
        }

        private void ValidateBooking(Booking booking)
        {
            // AcceptTerms is validated by the attribute on the model only.

            var nowSast = DateTime.UtcNow + SastOffset;
            var todaySast = nowSast.Date;

            if (!string.IsNullOrWhiteSpace(booking.Service) &&
                !BookingOptions.Services.Contains(booking.Service))
            {
                ModelState.AddModelError(nameof(booking.Service), "Please select a valid service.");
            }

            if (!string.IsNullOrWhiteSpace(booking.EventType) &&
                !BookingOptions.EventTypes.Contains(booking.EventType))
            {
                ModelState.AddModelError(nameof(booking.EventType), "Please select a valid event type.");
            }

            if (booking.Date.HasValue)
            {
                var date = booking.Date.Value.Date;

                if (date < todaySast)
                {
                    ModelState.AddModelError(nameof(booking.Date), "The booking date cannot be in the past.");
                }
                else if (date == todaySast &&
                         booking.StartTime.HasValue &&
                         booking.StartTime.Value <= nowSast.TimeOfDay)
                {
                    ModelState.AddModelError(nameof(booking.StartTime), "The start time has already passed today.");
                }
            }

            if (booking.StartTime.HasValue &&
                booking.FinishTime.HasValue &&
                booking.FinishTime.Value <= booking.StartTime.Value)
            {
                ModelState.AddModelError(
                    nameof(booking.FinishTime),
                    "The finish time must be later than the start time.");
            }

            if (booking.Latitude is < -90 or > 90)
            {
                ModelState.AddModelError(
                    nameof(booking.Location),
                    "The selected location has an invalid latitude.");
            }

            if (booking.Longitude is < -180 or > 180)
            {
                ModelState.AddModelError(
                    nameof(booking.Location),
                    "The selected location has an invalid longitude.");
            }
        }
    }
}