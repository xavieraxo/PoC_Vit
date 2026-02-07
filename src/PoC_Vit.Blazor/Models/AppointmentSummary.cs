namespace PoC_Vit.Blazor.Models;

public class AppointmentSummary
{
    public long Id { get; set; }
    public string BookedBy { get; set; } = "";
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime StartUtc { get; set; }
    public string ProfessionalName { get; set; } = "";
    public string Specialty { get; set; } = "";
    public long SlotId { get; set; }
}
