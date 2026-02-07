using Microsoft.AspNetCore.Components.Authorization;
using System.Security.Claims;
using System.Text.Json;
using Microsoft.JSInterop;
using System.Net.Http.Headers;

namespace PoC_Vit.Blazor.Services;

public class CustomAuthStateProvider : AuthenticationStateProvider
{
    private readonly IJSRuntime _jsRuntime;
    private readonly HttpClient _http;

    public CustomAuthStateProvider(IJSRuntime jsRuntime, HttpClient http)
    {
        _jsRuntime = jsRuntime;
        _http = http;
    }

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        var token = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", "authToken");

        if (string.IsNullOrWhiteSpace(token))
        {
            return new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity()));
        }

        _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);

        return new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity(ParseClaimsFromJwt(token), "jwt")));
    }

    public void UpdateAuthenticationState(string? token, string? username, string? role)
    {
        ClaimsPrincipal claimsPrincipal;

        if (token != null)
        {
            _jsRuntime.InvokeVoidAsync("localStorage.setItem", "authToken", token);
            _jsRuntime.InvokeVoidAsync("localStorage.setItem", "username", username);
            _jsRuntime.InvokeVoidAsync("localStorage.setItem", "role", role);
            
            _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", token);
            claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity(new[] 
            { 
                new Claim(ClaimTypes.Name, username!), 
                new Claim(ClaimTypes.Role, role!) 
            }, "jwt"));
        }
        else
        {
            _jsRuntime.InvokeVoidAsync("localStorage.removeItem", "authToken");
            _jsRuntime.InvokeVoidAsync("localStorage.removeItem", "username");
            _jsRuntime.InvokeVoidAsync("localStorage.removeItem", "role");
            
            _http.DefaultRequestHeaders.Authorization = null;
            claimsPrincipal = new ClaimsPrincipal(new ClaimsIdentity());
        }

        NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(claimsPrincipal)));
    }

    private IEnumerable<Claim> ParseClaimsFromJwt(string jwt)
    {
        var payload = jwt.Split('.')[1];
        var jsonBytes = ParseBase64WithoutPadding(payload);
        var keyValuePairs = JsonSerializer.Deserialize<Dictionary<string, object>>(jsonBytes);
        return keyValuePairs!.Select(kvp => new Claim(kvp.Key, kvp.Value.ToString()!));
    }

    private byte[] ParseBase64WithoutPadding(string base64)
    {
        switch (base64.Length % 4)
        {
            case 2: base64 += "=="; break;
            case 3: base64 += "="; break;
        }
        return Convert.FromBase64String(base64);
    }
}
