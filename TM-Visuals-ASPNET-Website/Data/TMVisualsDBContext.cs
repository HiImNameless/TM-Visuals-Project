using Microsoft.EntityFrameworkCore;

namespace TMVisualsWebApp.Data
{
    public class TMVisualsDBContext : DbContext
    {

        public TMVisualsDBContext(DbContextOptions<TMVisualsDBContext> options)
            : base(options)
        {
        }
        // Add DbSet properties for your entities here
        // Example:
        // public DbSet<YourEntity> YourEntities { get; set; }
    }
}
