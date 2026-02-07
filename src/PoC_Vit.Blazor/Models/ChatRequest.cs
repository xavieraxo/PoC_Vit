namespace PoC_Vit.Blazor.Models;

public class ChatRequest
{
    public string Message { get; set; } = "";
    public Guid ConversationId { get; set; }
}

