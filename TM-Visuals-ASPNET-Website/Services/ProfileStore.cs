namespace TMVisualsWebApp.Services
{
    /// <summary>
    /// In-memory stand-in for a profiles table. Replace with a Supabase-backed
    /// version later; the controller only calls Get and Save.
    /// </summary>
    public class ProfileStore
    {
        private readonly object _lock = new();
        private readonly Dictionary<string, (string? Name, string? Phone)> _profiles =
            new(StringComparer.OrdinalIgnoreCase);

        public (string? Name, string? Phone) Get(string email)
        {
            lock (_lock)
            {
                return _profiles.TryGetValue(email, out var p) ? p : (null, null);
            }
        }

        public void Save(string email, string? name, string? phone)
        {
            lock (_lock)
            {
                _profiles[email] = (name, phone);
            }
        }
    }
}
