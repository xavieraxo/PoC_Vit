namespace PoC_Vit.Blazor.Models;

public class AppointmentResponse
{
    public long AppointmentId { get; set; }
    public long SlotId { get; set; }
    public DateTime CreatedAt { get; set; }
    public long ProfessionalId { get; set; }
}

