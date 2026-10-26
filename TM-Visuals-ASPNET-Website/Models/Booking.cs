namespace TMVisualsWebApp.Models
{
    public class Booking
    {
        public int Id { get; set; }
        public string Service { get; set; }
        public string Date { get; set; }
        public string Status { get; set; }

        public string Name { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public string EventType { get; set; }
        public int NumberOfPeople { get; set; }
        public string Location { get; set; }
        public string StartTime { get; set; }
        public string FinishTime { get; set; }
    }
}