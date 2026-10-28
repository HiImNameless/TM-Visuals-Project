using System.Collections.Generic;

namespace TMVisualsWebApp.Models
{
    public class UserProfile
    {
        public string FullName { get; set; }
        public string Email { get; set; }

        public string? PhoneNumber { get; set;}
        public List<Booking> Bookings { get; set; }
    }
}
