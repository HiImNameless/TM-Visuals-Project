using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using System.Linq;
using TMVisualsWebApp.Models;

namespace TMVisualsWebApp.Controllers
{
    public class HomeController : Controller
    {
        private static List<Booking> bookings = new List<Booking>
        {
             new Booking
             {
                 Id = 1,
                 Name = "Musa Bonga",
                 Phone = "07123456789",
                 Email = "user@email.com",
                 Service = "Photography",
                 EventType = "Wedding",
                 NumberOfPeople = 25,
                 Location = "Johannesburg, Sandton",
                 Date = "2026, December 14",
                 StartTime = "11:00 AM",
                 FinishTime = "16:00 PM",
                 Status = "Pending"
             },
             new Booking
             {
                 Id = 2,
                 Name = "Musa Bonga",
                 Phone = "07123456789",
                 Email = "user@email.com",
                 Service = "Video",
                 EventType = "Birthday Party",
                 NumberOfPeople = 40,
                 Location = "Cape Town",
                 Date = "2026, October 10",
                 StartTime = "13:00 PM",
                 FinishTime = "17:00 PM",
                 Status = "Confirmed"
              }
         };


        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
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

        public IActionResult MyWork()
        {
            return View();
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
                Bookings = bookings
            };

            return View(user);
        }

        public IActionResult BookingStatus(int id)
        {
            var booking = bookings.FirstOrDefault(b => b.Id == id);

            if (booking == null)
            {
                return NotFound();
            }

            return View(booking);
        }

        //Client Content Section
        private static readonly List<ClientContent> contentItems = new()
{
        new ClientContent 
                {
                    ContentId = Guid.NewGuid(),
                    EventType = "Graduation Shoot",
                    Service = new List<string> { "Photography", "Videography" },
                    BookingDate = new DateTime(2026,12,25),
                    StartTime = "13:00",
                    EndTime = "17:00",
                    Location = "CUT",
                    DeliveryLink = "https://example.com/download1",
                    AccessStatus = "Available"
                   },
        new ClientContent
                {
                    ContentId = Guid.NewGuid(),
                    EventType = "Wedding Shoot",
                    Service = new List<string> { "Photography", "Videography" },
                    BookingDate = new DateTime(2026,12,31),
                    StartTime = "10:00",
                    EndTime = "18:00",
                    Location = "Bloem Hall",
                    DeliveryLink = "https://example.com/download2",
                    AccessStatus = "Available"
                }
        };
        public IActionResult MyContent()
        {
            return View(contentItems);
        }
        public IActionResult Download(string url)
        {
            return Redirect(url);
        }
        //End Client Content Section

        [HttpGet]
        public IActionResult EditDetails()
        {
            // Use the same UserProfile object your Profile() action uses
            var profile = new UserProfile { FullName = "Musa Bonga", Email = "musa@example.com"};
            return View(profile);
        }

        [HttpPost]
        public IActionResult EditDetails(UserProfile model)
        {
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
