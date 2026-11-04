using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using System.Globalization;
using System.Text;
using System.Text.Json;

namespace TMVisualsWebApp.Services
{
    /// <summary>
    /// Keeps the signed-in user's Supabase access token available to the app.
    /// The token is stored (encrypted) in the sign-in cookie at login and is
    /// refreshed shortly before it expires. The database functions use it so
    /// that auth.uid() and row-level security work for the signed-in user.
    /// </summary>
    public sealed class SupabaseSessionService
    {
        public const string AccessTokenName = "access_token";
        public const string RefreshTokenName = "refresh_token";
        public const string ExpiresAtName = "expires_at";

        private static readonly TimeSpan RefreshMargin = TimeSpan.FromSeconds(60);

        private readonly IHttpClientFactory _httpClientFactory;
        private readonly IConfiguration _configuration;
        private readonly ILogger<SupabaseSessionService> _logger;

        public SupabaseSessionService(
            IHttpClientFactory httpClientFactory,
            IConfiguration configuration,
            ILogger<SupabaseSessionService> logger)
        {
            _httpClientFactory = httpClientFactory;
            _configuration = configuration;
            _logger = logger;
        }

        /// <summary>
        /// Returns a valid access token for the current user, or null when there
        /// isn't one (not signed in, signed in before tokens were stored, or the
        /// session could not be refreshed). Callers should treat null as
        /// "sign in again". Call this before the response starts, because a
        /// refresh re-issues the sign-in cookie.
        /// </summary>
        public async Task<string?> GetAccessTokenAsync(
            HttpContext context,
            CancellationToken cancellationToken = default)
        {
            var auth = await context.AuthenticateAsync(
                CookieAuthenticationDefaults.AuthenticationScheme);

            if (!auth.Succeeded || auth.Principal is null || auth.Properties is null)
            {
                return null;
            }

            var access = auth.Properties.GetTokenValue(AccessTokenName);
            if (string.IsNullOrWhiteSpace(access))
            {
                return null;
            }

            if (DateTimeOffset.TryParse(
                    auth.Properties.GetTokenValue(ExpiresAtName),
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.RoundtripKind,
                    out var expiresAt) &&
                expiresAt - DateTimeOffset.UtcNow > RefreshMargin)
            {
                return access;
            }

            var refresh = auth.Properties.GetTokenValue(RefreshTokenName);
            if (string.IsNullOrWhiteSpace(refresh))
            {
                return null;
            }

            var renewed = await RefreshAsync(refresh, cancellationToken);
            if (renewed is null)
            {
                return null;
            }

            auth.Properties.UpdateTokenValue(AccessTokenName, renewed.AccessToken);
            auth.Properties.UpdateTokenValue(RefreshTokenName, renewed.RefreshToken);
            auth.Properties.UpdateTokenValue(
                ExpiresAtName,
                renewed.ExpiresAt.ToString("o", CultureInfo.InvariantCulture));

            await context.SignInAsync(
                CookieAuthenticationDefaults.AuthenticationScheme,
                auth.Principal,
                auth.Properties);

            return renewed.AccessToken;
        }

        private async Task<RenewedSession?> RefreshAsync(
            string refreshToken,
            CancellationToken cancellationToken)
        {
            var url = _configuration["Supabase:Url"]?.TrimEnd('/');
            var key = _configuration["Supabase:Key"]?.Trim();

            if (string.IsNullOrWhiteSpace(url) || string.IsNullOrWhiteSpace(key))
            {
                return null;
            }

            using var request = new HttpRequestMessage(
                HttpMethod.Post,
                $"{url}/auth/v1/token?grant_type=refresh_token");
            request.Headers.TryAddWithoutValidation("apikey", key);
            request.Content = new StringContent(
                JsonSerializer.Serialize(new { refresh_token = refreshToken }),
                Encoding.UTF8,
                "application/json");

            try
            {
                var client = _httpClientFactory.CreateClient("SupabaseAuth");
                using var response = await client.SendAsync(request, cancellationToken);

                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning(
                        "Supabase token refresh failed with HTTP {Status}.",
                        (int)response.StatusCode);
                    return null;
                }

                using var document = JsonDocument.Parse(
                    await response.Content.ReadAsStringAsync(cancellationToken));
                var root = document.RootElement;

                var access = root.GetProperty("access_token").GetString();
                var refresh = root.GetProperty("refresh_token").GetString();
                var expiresIn = root.TryGetProperty("expires_in", out var expiresElement) &&
                                expiresElement.TryGetInt32(out var seconds)
                    ? seconds
                    : 3600;

                if (string.IsNullOrWhiteSpace(access) || string.IsNullOrWhiteSpace(refresh))
                {
                    return null;
                }

                return new RenewedSession(
                    access,
                    refresh,
                    DateTimeOffset.UtcNow.AddSeconds(expiresIn));
            }
            catch (Exception error) when (
                error is HttpRequestException or
                JsonException or
                KeyNotFoundException or
                TaskCanceledException)
            {
                _logger.LogWarning(error, "Supabase token refresh failed.");
                return null;
            }
        }

        private sealed record RenewedSession(
            string AccessToken,
            string RefreshToken,
            DateTimeOffset ExpiresAt);
    }
}
