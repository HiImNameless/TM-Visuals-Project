using Microsoft.EntityFrameworkCore.Metadata.Internal;
using Microsoft.Identity.Client;

namespace TMVisualsWebApp.Models
{
    public class ClientContent
    {
        
        public Guid ContentId { get; set; }
        public Guid BookingId { get; set; }

        //Add-ons properties
        public string EventType { get; set; } = string.Empty;
        public List<string> Service { get; set; } = new List<string>();
        public string StartTime { get; set; } = string.Empty;
        public string EndTime { get; set; } = string.Empty;
        public string Location { get; set; } = string.Empty;
        //End Add-ons
        public DateTime BookingDate { get; set; }
        public string DeliveryLink { get; set; } = string.Empty;
        public string AccessStatus { get; set; } = string.Empty;
        
    }
}
