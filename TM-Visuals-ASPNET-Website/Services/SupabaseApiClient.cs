using System.Globalization;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace TMVisualsWebApp.Services;

public sealed class SupabaseSignInRequiredException : Exception;

public sealed class SupabaseApiException(HttpStatusCode statusCode, string? code, string? databaseMessage = null)
    : Exception($"Supabase request failed (HTTP {(int)statusCode}).")
{
    public HttpStatusCode StatusCode { get; } = statusCode;
    public string? Code { get; } = code;
    public string? DatabaseMessage { get; } = databaseMessage;
}

/// Uses public credentials and the caller's session. Tokens stay inside the
/// encrypted, HttpOnly ASP.NET auth cookie; booking ownership is enforced by SQL.
public sealed class SupabaseApiClient(
    HttpClient client, IConfiguration configuration, IHttpContextAccessor contexts)
{
    public async Task<JsonElement> RpcAsync(string name, object body,
        bool authenticated = false, CancellationToken cancellationToken = default)
    {
        var (url, key) = Settings();
        using var request = new HttpRequestMessage(HttpMethod.Post, $"{url}/rest/v1/rpc/{name}");
        request.Headers.TryAddWithoutValidation("apikey", key);
        if (authenticated)
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", await AccessTokenAsync(cancellationToken));
        else if (key.StartsWith("eyJ", StringComparison.Ordinal))
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", key);
        request.Content = JsonContent.Create(body);
        using var response = await client.SendAsync(request, cancellationToken);
        if (authenticated && response.StatusCode == HttpStatusCode.Unauthorized)
        {
            await contexts.HttpContext!.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            throw new SupabaseSignInRequiredException();
        }
        var json = await response.Content.ReadAsStringAsync(cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            string? code = null;
            string? databaseMessage = null;
            try
            {
                using var error = JsonDocument.Parse(json);
                var root = error.RootElement;
                if (root.ValueKind == JsonValueKind.Object)
                {
                    if (root.TryGetProperty("code", out var errorCode) && errorCode.ValueKind == JsonValueKind.String)
                        code = errorCode.GetString();
                    if (root.TryGetProperty("message", out var errorMessage) && errorMessage.ValueKind == JsonValueKind.String)
                        databaseMessage = errorMessage.GetString();
                }
            }
            catch (JsonException) { }
            throw new SupabaseApiException(response.StatusCode, code, databaseMessage);
        }
        using var document = JsonDocument.Parse(string.IsNullOrWhiteSpace(json) ? "null" : json);
        return document.RootElement.Clone();
    }

    private (string Url, string Key) Settings()
    {
        var url = configuration["Supabase:Url"]?.TrimEnd('/');
        var key = configuration["Supabase:Key"]?.Trim();
        if (!Uri.TryCreate(url, UriKind.Absolute, out var uri) ||
            (uri.Scheme != Uri.UriSchemeHttps && uri.Scheme != Uri.UriSchemeHttp) || string.IsNullOrWhiteSpace(key))
            throw new InvalidOperationException("Supabase is not configured.");
        return (url!, key);
    }

    public async Task<string> AccessTokenAsync(CancellationToken cancellationToken)
    {
        var context = contexts.HttpContext ?? throw new SupabaseSignInRequiredException();
        var auth = await context.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        var properties = auth.Properties;
        var access = properties?.GetTokenValue("access_token");
        if (!auth.Succeeded || properties == null || string.IsNullOrWhiteSpace(access))
            throw new SupabaseSignInRequiredException();
        if (DateTimeOffset.TryParse(properties.GetTokenValue("expires_at"), CultureInfo.InvariantCulture,
            DateTimeStyles.RoundtripKind, out var expiry) && expiry > DateTimeOffset.UtcNow.AddMinutes(1))
            return access;
        var refresh = properties.GetTokenValue("refresh_token");
        if (string.IsNullOrWhiteSpace(refresh)) throw new SupabaseSignInRequiredException();
        var (url, key) = Settings();
        using var request = new HttpRequestMessage(HttpMethod.Post, $"{url}/auth/v1/token?grant_type=refresh_token");
        request.Headers.TryAddWithoutValidation("apikey", key);
        request.Content = JsonContent.Create(new { refresh_token = refresh });
        using var response = await client.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            if (response.StatusCode is HttpStatusCode.BadRequest or HttpStatusCode.Unauthorized)
            {
                await context.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
                throw new SupabaseSignInRequiredException();
            }
            throw new HttpRequestException("The sign-in service is temporarily unavailable.");
        }
        using var doc = JsonDocument.Parse(await response.Content.ReadAsStringAsync(cancellationToken));
        var root = doc.RootElement;
        if (root.GetProperty("user").GetProperty("id").GetString() != auth.Principal!.FindFirstValue(ClaimTypes.NameIdentifier))
            throw new SupabaseSignInRequiredException();
        var token = root.GetProperty("access_token").GetString();
        var nextRefresh = root.GetProperty("refresh_token").GetString();
        if (string.IsNullOrWhiteSpace(token) || string.IsNullOrWhiteSpace(nextRefresh))
            throw new SupabaseSignInRequiredException();
        properties.StoreTokens([
            new() { Name="access_token", Value=token },
            new() { Name="refresh_token", Value=nextRefresh },
            new() { Name="expires_at", Value=DateTimeOffset.UtcNow.AddSeconds(root.GetProperty("expires_in").GetInt32()).ToString("O",CultureInfo.InvariantCulture) },
        ]);
        await context.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, auth.Principal!, properties);
        return token;
    }
}
