
using System.Net.Http.Json;
using System.Security.Claims;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using TMVisualsWebApp.Models.Account;

namespace TMVisualsWebApp.Controllers
{
    public class AccountController : Controller
    {
        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;

        public AccountController(
            //Inject IHttpClientFactory and IConfiguration into the controller
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
        }

        [HttpGet]
        public IActionResult Register()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Register(
            RegisterViewModel model)
        {
            if (!ModelState.IsValid)
                return View(model);

            if (!TryGetSupabaseAuthSettings(out var url, out var key))
                return View(model);

            var client = _httpClientFactory.CreateClient("SupabaseAuth");

            using var request = new HttpRequestMessage(
                HttpMethod.Post, $"{url}/auth/v1/signup");

            request.Headers.Add("apikey", key);
            request.Content = JsonContent.Create(new
            {
                email = model.Email,
                password = model.Password
            });

            using var response = await client.SendAsync(request);

            if (!response.IsSuccessStatusCode)
            {
                ModelState.AddModelError(
                    string.Empty,
                    "Registration failed. Check your details and try again.");

                return View(model);
            }

            TempData["Message"] =
                "Registration submitted. Check your email if confirmation is required.";

            return RedirectToAction(nameof(Login));
        }

        [HttpGet]
        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(
            LoginViewModel model)
        {
            if (!ModelState.IsValid)
                return View(model);

            if (!TryGetSupabaseAuthSettings(out var url, out var key))
                return View(model);

            var client = _httpClientFactory.CreateClient("SupabaseAuth");

            using var request = new HttpRequestMessage(
                HttpMethod.Post,
                $"{url}/auth/v1/token?grant_type=password");

            request.Headers.Add("apikey", key);
            request.Content = JsonContent.Create(new
            {
                email = model.Email,
                password = model.Password
            });

            using var response = await client.SendAsync(request);

            if (!response.IsSuccessStatusCode)
            {
                ModelState.AddModelError(
                    string.Empty,
                    "Invalid email or password.");

                return View(model);
            }

            var result = await response.Content
                .ReadFromJsonAsync<SupabaseLoginResponse>();

            if (result?.User?.Id is not string userId ||
                string.IsNullOrWhiteSpace(userId))
            {
                ModelState.AddModelError(
                    string.Empty,
                    "Unable to complete sign-in.");

                return View(model);
            }

            var email = result.User.Email ?? model.Email;

            var claims = new List<Claim>
            {
                new(ClaimTypes.NameIdentifier, userId),
                new(ClaimTypes.Name, email),
                new(ClaimTypes.Email, email)
            };

            var identity = new ClaimsIdentity(
                claims,
                CookieAuthenticationDefaults.AuthenticationScheme);

            var principal = new ClaimsPrincipal(identity);

            await HttpContext.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                principal,
                new AuthenticationProperties
                {
                    IsPersistent = model.RememberMe,
                    ExpiresUtc = DateTimeOffset.UtcNow.AddHours(
                        model.RememberMe ? 24 : 2)
                });

            return RedirectToAction("Index", "Home");
        }

        private bool TryGetSupabaseAuthSettings(out string url, out string key)
        {
            url = _configuration["Supabase:Url"]?.TrimEnd('/') ?? string.Empty;
            key = _configuration["Supabase:Key"] ?? string.Empty;

            if (Uri.TryCreate(url, UriKind.Absolute, out var projectUri) &&
                (projectUri.Scheme == Uri.UriSchemeHttps ||
                 projectUri.Scheme == Uri.UriSchemeHttp) &&
                !string.IsNullOrWhiteSpace(key))
            {
                return true;
            }

            ModelState.AddModelError(
                string.Empty,
                "Supabase Auth is not configured. Set Supabase:Url and Supabase:Key using .NET User Secrets.");
            return false;
        }

        private sealed class SupabaseLoginResponse
        {
            [JsonPropertyName("user")]
            public SupabaseUser? User { get; set; }
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(
                CookieAuthenticationDefaults.AuthenticationScheme);

            return RedirectToAction("Index", "Home");
        }

        private sealed class SupabaseUser
        {
            [JsonPropertyName("id")]
            public string? Id { get; set; }

            [JsonPropertyName("email")]
            public string? Email { get; set; }
        }
    }
}
