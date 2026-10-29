using System.ComponentModel.DataAnnotations;

namespace TMVisualsWebApp.Models
{
    public enum ContentAccessStatus
    {
        Pending,
        Available,
        Expired
    }

    public class ClientContent
    {
        public int ContentId { get; set; }
        public int BookingId { get; set; }          // matches Booking.Id

        public string EventType { get; set; } = string.Empty;
        public List<string> Services { get; set; } = new();
        public string Location { get; set; } = string.Empty;

        [DataType(DataType.Date)]
        public DateTime BookingDate { get; set; }

        public TimeSpan? StartTime { get; set; }
        public TimeSpan? FinishTime { get; set; }

        [Url]
        public string? DeliveryLink { get; set; }   // null until the content is ready
        public ContentAccessStatus AccessStatus { get; set; } = ContentAccessStatus.Pending;
    }
}