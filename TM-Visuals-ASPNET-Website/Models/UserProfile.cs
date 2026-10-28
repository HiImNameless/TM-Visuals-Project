using System.Collections.Generic;

namespace TMVisualsWebApp.Models
{
    public class UserProfile
    {
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public List<Booking> Bookings { get; set; } = new();
    }
}
