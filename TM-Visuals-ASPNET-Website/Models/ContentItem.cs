namespace TMVisualsWebApp.Models
{
    public class ContentItem
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public TimeSpan Time { get; set; }
        public int Hours { get; set; }
        public string Location { get; set; } = "";
        public string DownloadUrl { get; set; } = "#";
    }
}
