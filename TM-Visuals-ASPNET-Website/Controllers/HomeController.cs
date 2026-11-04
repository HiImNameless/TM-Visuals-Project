using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using System.Security.Claims;
using System.Text.Json;
using TMVisualsWebApp.Models;
using TMVisualsWebApp.Services;

namespace TMVisualsWebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly PortfolioCatalogService _portfolioCatalog;
        private readonly ServicesCatalogService _servicesCatalog;
        private readonly InvoiceCatalogService _invoiceCatalog;
        private readonly SupabaseDataService _data;
        private readonly SupabaseSessionService _session;

        public HomeController(
            ILogger<HomeController> logger,
            PortfolioCatalogService portfolioCatalog,
            ServicesCatalogService servicesCatalog,
            InvoiceCatalogService invoiceCatalog,
            SupabaseDataService data,
            SupabaseSessionService session)
        {
            _logger = logger;
            _portfolioCatalog = portfolioCatalog;
            _servicesCatalog = servicesCatalog;
            _invoiceCatalog = invoiceCatalog;
            _data = data;
            _session = session;
        }

        private bool TryGetUserId(out Guid userId) =>
            Guid.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out userId);

        // Problems reaching or reading Supabase, as opposed to bugs.
        private static bool IsDataError(Exception error) =>
            error is HttpRequestException or
            SupabaseDataException or
            InvalidOperationException or
            JsonException;

        public IActionResult Index()
        {
            return View();
        }



        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public async Task<IActionResult> Services(
            CancellationToken cancellationToken)
        {
            try
            {
                var services = await _servicesCatalog.FetchActiveServicesAsync(
                    cancellationToken);
                return View(services);
            }
            catch (Exception error) when (
                error is HttpRequestException ||
                error is InvalidOperationException ||
                error is JsonException)
            {
                _logger.LogError(error, "Could not load the public services.");
                ViewData["ServicesError"] =
                    "Services are temporarily unavailable. Please try again later.";
                return View(new List<ServiceItem>());
            }
        }

        public async Task<IActionResult> MyWork(CancellationToken cancellationToken)
        {
            try
            {
                var myWork = await _portfolioCatalog.FetchPublicItemsAsync(
                    cancellationToken);
                return View(myWork);
            }
            catch (Exception error) when (
                error is HttpRequestException ||
                error is InvalidOperationException ||
                error is JsonException)
            {
                _logger.LogError(error, "Could not load the public portfolio.");
                ViewData["PortfolioError"] =
                    "Portfolio items are temporarily unavailable. Please try again later.";
                return View(new List<PortfolioItem>());
            }
        }

        [Authorize]
        public IActionResult Booking()
        {
            return View();
        }

        [Authorize]
        public async Task<IActionResult> Profile(CancellationToken cancellationToken)
        {
            var email = User.FindFirstValue(ClaimTypes.Email) ?? string.Empty;

            if (!TryGetUserId(out var userId))
            {
                return Forbid();
            }

            // Signed in before tokens were stored, or the session expired.
            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            var myBookings = new List<Booking>();
            SupabaseProfile? saved = null;
            try
            {
                myBookings = (await _data.GetMyBookingsAsync(accessToken, userId, cancellationToken))
                    .OrderByDescending(b => b.Date)
                    .ToList();
                saved = await _data.GetMyProfileAsync(accessToken, userId, cancellationToken);
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not load the profile and bookings for {Email}.", email);
                TempData["BookingsError"] = "Your bookings are temporarily unavailable.";
            }

            IReadOnlyList<InvoiceDownload> invoices;
            try
            {
                invoices = await _invoiceCatalog.FetchForClientAsync(
                    email, cancellationToken, accessToken);
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not load invoices for {Email}.", email);
                invoices = Array.Empty<InvoiceDownload>();
                TempData["InvoiceError"] = "Invoices are temporarily unavailable.";
            }

            var user = new UserProfile
            {
                FullName = saved?.FullName is { Length: > 0 } name
                    ? name
                    : email.Split('@')[0],
                Email = email,
                PhoneNumber = saved?.Phone,
                Bookings = myBookings,
                Invoices = invoices.ToList()
            };

            return View(user);
        }

        [Authorize]
        public async Task<IActionResult> DownloadInvoice(
            string id,
            CancellationToken cancellationToken)
        {
            var email = User.FindFirstValue(ClaimTypes.Email) ?? string.Empty;

            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            var invoice = (await _invoiceCatalog.FetchForClientAsync(
                    email, cancellationToken, accessToken))
                .FirstOrDefault(item => string.Equals(item.Id, id, StringComparison.Ordinal));

            if (invoice == null)
            {
                return NotFound();
            }

            var downloadUrl = await _invoiceCatalog.CreateSignedDownloadUrlAsync(
                invoice.FilePath,
                invoice.Reference,
                cancellationToken,
                accessToken);
            return Redirect(downloadUrl);
        }

        [Authorize]
        public async Task<IActionResult> BookingStatus(
            Guid id,
            CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId))
            {
                return Forbid();
            }

            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            Booking? booking;
            try
            {
                booking = await _data.GetMyBookingAsync(
                    accessToken, userId, id, cancellationToken);
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not load booking {BookingId}.", id);
                return StatusCode(StatusCodes.Status503ServiceUnavailable);
            }

            if (booking == null)
            {
                return NotFound();
            }

            return View(booking);
        }

        [Authorize]
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> CancelBooking(
            Guid id,
            CancellationToken cancellationToken)
        {
            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            try
            {
                await _data.CancelBookingAsync(accessToken, id, cancellationToken);
            }
            catch (SupabaseDataException error) when (error.StatusCode is >= 400 and < 500)
            {
                // Not this user's booking, or it can no longer be cancelled.
                _logger.LogWarning(
                    "Booking {BookingId} was not cancelled: {Message}", id, error.Message);
                return NotFound();
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not cancel booking {BookingId}.", id);
                TempData["BookingsError"] = "We couldn't cancel that booking. Please try again.";
                return RedirectToAction(nameof(Profile));
            }

            return RedirectToAction(nameof(CancellationNotification));
        }

        [Authorize]
        public IActionResult CancellationNotification()
        {
            return View();
        }




        // DELETE this entire block:
        // private static readonly List<ClientContent> contentItems = new() { ... };

        // REPLACE MyContent() with:
        [Authorize]
        public async Task<IActionResult> MyContent(CancellationToken cancellationToken)
        {
            if (!TryGetUserId(out var userId))
            {
                return Forbid();
            }

            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            var bookings = new List<Booking>();
            try
            {
                bookings = await _data.GetMyBookingsAsync(accessToken, userId, cancellationToken);
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not load the content for the signed-in user.");
                ViewData["ContentError"] = "Your content is temporarily unavailable.";
            }

            var items = bookings
                .Where(b => (b.Status == "Confirmed" || b.Status == "Completed")
                         && b.Date.HasValue)
                .OrderByDescending(b => b.Date)
                .Select(b => new ClientContent(b))
                .ToList();

            return View(items);
        }

        [Authorize]
        [HttpGet]
        public async Task<IActionResult> EditDetails(CancellationToken cancellationToken)
        {
            var email = User.FindFirstValue(ClaimTypes.Email) ?? string.Empty;

            if (!TryGetUserId(out var userId))
            {
                return Forbid();
            }

            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            SupabaseProfile? saved = null;
            try
            {
                saved = await _data.GetMyProfileAsync(accessToken, userId, cancellationToken);
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not load the profile for {Email}.", email);
            }

            var profile = new UserProfile
            {
                FullName = saved?.FullName is { Length: > 0 } name
                    ? name
                    : email.Split('@')[0],
                Email = email,
                PhoneNumber = saved?.Phone
            };

            return View(profile);
        }

        [Authorize]
        [HttpPost]
        public async Task<IActionResult> EditDetails(
            UserProfile model,
            CancellationToken cancellationToken)
        {
            ModelState.Remove("Bookings");
            ModelState.Remove("Invoices");

            // The email is the login, so always use the one from the cookie
            var email = User.FindFirstValue(ClaimTypes.Email) ?? string.Empty;
            model.Email = email;
            ModelState.Remove("Email");

            if (string.IsNullOrWhiteSpace(model.FullName))
            {
                ModelState.AddModelError(nameof(model.FullName), "Please enter your name.");
            }

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var accessToken = await _session.GetAccessTokenAsync(HttpContext, cancellationToken);
            if (accessToken is null)
            {
                return Challenge();
            }

            try
            {
                await _data.UpdateMyProfileAsync(
                    accessToken,
                    model.FullName.Trim(),
                    model.PhoneNumber?.Trim(),
                    cancellationToken);
            }
            catch (Exception error) when (IsDataError(error))
            {
                _logger.LogError(error, "Could not update the profile for {Email}.", email);
                ModelState.AddModelError(
                    string.Empty,
                    "We couldn't save your details. Please try again.");
                return View(model);
            }

            TempData["Message"] = "Details updated.";
            return RedirectToAction("Profile");
        }


    }
}