namespace TMVisualsWebApp.Models
{
    public class BookingConfirmationViewModel
    {
        public Guid BookingId { get; set; }

        public string Name { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Service { get; set; } = string.Empty;
        public string EventType { get; set; } = string.Empty;

        public DateTime? Date { get; set; }
        public TimeSpan? StartTime { get; set; }
        public TimeSpan? FinishTime { get; set; }

        public string Location { get; set; } = string.Empty;
        public decimal? Budget { get; set; }
        public string WhatsAppUrl { get; set; } = string.Empty;
        public int? NumberOfPeople { get; set; }
        public string Status { get; set; } = "Pending";
        

    }
}
