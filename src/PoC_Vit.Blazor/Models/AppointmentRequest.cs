namespace PoC_Vit.Blazor.Models;

public class AppointmentRequest
{
    public long ProfessionalId { get; set; }
    public DateTime StartUtc { get; set; }
    public string BookedBy { get; set; } = "";
    public string? Notes { get; set; }
}

