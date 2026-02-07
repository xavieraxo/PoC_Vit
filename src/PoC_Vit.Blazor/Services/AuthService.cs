using System.Net.Http.Json;
using System.Text.Json;
using PoC_Vit.Blazor.Models;
using Microsoft.AspNetCore.Components.Authorization;
using System.Security.Claims;

namespace PoC_Vit.Blazor.Services;

public class AuthService
{
    private readonly HttpClient _http;
    private readonly AuthenticationStateProvider _authStateProvider;

    public AuthService(HttpClient http, AuthenticationStateProvider authStateProvider)
    {
        _http = http;
        _authStateProvider = authStateProvider;
    }

    public async Task<bool> LoginAsync(string username, string password)
    {
        var response = await _http.PostAsJsonAsync("auth/login", new { username, password });
        if (response.IsSuccessStatusCode)
        {
            var result = await response.Content.ReadFromJsonAsync<LoginResponse>();
            if (result != null)
            {
                ((CustomAuthStateProvider)_authStateProvider).UpdateAuthenticationState(result.Token, result.Username, result.Role);
                return true;
            }
        }
        return false;
    }

    public void Logout()
    {
        ((CustomAuthStateProvider)_authStateProvider).UpdateAuthenticationState(null, null, null);
    }
}

public class LoginResponse
{
    public string Token { get; set; } = "";
    public string Username { get; set; } = "";
    public string Role { get; set; } = "";
}
