namespace PoC_Vit.Blazor.Models;

public class DocumentSummary
{
    public long Id { get; set; }
    public string Title { get; set; } = "";
    public string? SourceUri { get; set; }
    public string? Type { get; set; }
    public DateTime UpdatedAt { get; set; }
}
