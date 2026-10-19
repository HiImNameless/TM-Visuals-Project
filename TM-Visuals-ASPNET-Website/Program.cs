using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Supabase.Extensions.DependencyInjection;
using TMVisualsWebApp.Data;
using TMVisualsWebApp.Models;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
//var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");
//builder.Services.AddDbContext<ApplicationDbContext>(options =>
    //options.UseSqlServer(connectionString));
builder.Services.AddDatabaseDeveloperPageExceptionFilter();
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("SupabaseConnection")));

builder.Services.AddDefaultIdentity<IdentityUser>(options => options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<ApplicationDbContext>();
builder.Services.AddControllersWithViews();


builder.Services.AddSupabase(
    builder.Configuration["Supabase:Url"]!,
    builder.Configuration["Supabase:Key"]!
);
// Registers Supabase.Client and each of its sub-clients (Auth, Postgrest,
// Storage, Functions, Realtime) in the DI container, backed by pooled
// HttpClients from IHttpClientFactory.
//
// Blazor registers the client the same way: use this in your Blazor Server /
// Web App Program.cs, or WebAssemblyHostBuilder.CreateDefault(args) for a
// Blazor WebAssembly client.


var app = builder.Build();

app.MapGet("/todos", async (Supabase.Client supabase) =>
{
        await supabase.InitializeAsync();
        var response = await supabase.From<Todo>().Get();
        return response.Models;
    });

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseMigrationsEndPoint();
}
else
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();

app.MapRazorPages()
   .WithStaticAssets();


app.Run();
