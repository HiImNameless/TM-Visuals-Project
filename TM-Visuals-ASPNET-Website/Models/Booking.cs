namespace TMVisualsWebApp.Models
{
    public class Booking
    {
        public int Id { get; set; }
        public string Service { get; set; } = string.Empty;
        public string Date { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;

        public string Name { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string EventType { get; set; } = string.Empty;
        public int NumberOfPeople { get; set; }
        public string Location { get; set; } = string.Empty;
        public string StartTime { get; set; } = string.Empty;
        public string FinishTime { get; set; } = string.Empty;
    }
}