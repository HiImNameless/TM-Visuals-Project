using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using TMVisualsWebApp.Models;
using TMVisualsWebApp.Services;
using System.Text.Json;

namespace TMVisualsWebApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly PortfolioCatalogService _portfolioCatalog;
        private readonly BookingStore _store;

        public HomeController(
            ILogger<HomeController> logger,
            PortfolioCatalogService portfolioCatalog,
            BookingStore store)
        {
            _logger = logger;
            _portfolioCatalog = portfolioCatalog;
            _store = store;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }

        public IActionResult Services()
        {
            return View();
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

        public IActionResult Booking()
        {
            return View();
        }

        public IActionResult Profile()
        {
            var user = new UserProfile
            {
                FullName = "Musa Bonga",
                Email = "musabonga@gmail.com",
                PhoneNumber = null,
                Bookings = _store.All()
            };

            return View(user);
        }

        public IActionResult BookingStatus(int id)
        {
            var booking = _store.All().FirstOrDefault(b => b.Id == id);

            if (booking == null)
            {
                return NotFound();
            }

            return View(booking);
        }


        private static readonly List<ClientContent> contentItems = new()
        {
            new ClientContent
            {
                ContentId = 1,
                BookingId = 1,
                EventType = "Graduation Shoot",
                Services = new List<string> { "Photography", "Videography" },
                BookingDate = new DateTime(2026, 12, 25),
                StartTime = new TimeSpan(13, 0, 0),
                FinishTime = new TimeSpan(17, 0, 0),
                Location = "CUT",
                DeliveryLink = "https://example.com/download1",
                AccessStatus = ContentAccessStatus.Available,
            },

            new ClientContent
            {
                ContentId = 2,
                BookingId = 2,
                EventType = "Wedding Shoot",
                Services = new List<string> { "Photography", "Videography" },
                BookingDate = new DateTime(2026, 12, 31),
                StartTime = new TimeSpan(10,0,0),
                FinishTime = new TimeSpan(18,0,0),
                Location = "Bloem Hall",
                DeliveryLink = "https://example.com/download2",
                AccessStatus = ContentAccessStatus.Pending,
            }
        };

        public IActionResult MyContent()
        {
            return View(contentItems);
        }

        [HttpGet]
        public IActionResult EditDetails()
        {
            // Use the same UserProfile object your Profile() action uses
            var profile = new UserProfile { FullName = "Musa Bonga", Email = "musa@example.com", PhoneNumber = null};
            return View(profile);
        }

        [HttpPost]
        public IActionResult EditDetails(UserProfile model)
        {
            ModelState.Remove("Bookings");

            if (!ModelState.IsValid)
            {
                return View(model);
            }

            // TODO: save to the database once Supabase is connected
            TempData["Message"] = "Details updated.";
            return RedirectToAction("Profile");
        }
    }
}
