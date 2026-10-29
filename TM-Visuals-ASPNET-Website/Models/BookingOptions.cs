namespace TMVisualsWebApp.Models
{
    /// <summary>
    /// Allowed values for the Service and EventType dropdowns.
    /// IMPORTANT: replace the placeholders below with the exact values
    /// your Create view posts (the option "value" attributes).
    /// </summary>
    public static class BookingOptions
    {
        public static readonly HashSet<string> Services = new(StringComparer.OrdinalIgnoreCase)
        {
            "Photography",
            "Videography",
            "Photography & Videography"
        };
        public static readonly HashSet<string> EventTypes = new(StringComparer.OrdinalIgnoreCase)
        {
            "Wedding",
            "Corporate Event",
            "Birthday",
            "Graduation",
            "Other"
        };
    }
}
