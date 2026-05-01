using Microsoft.Data.SqlClient;

var builder = WebApplication.CreateBuilder(args);
var connString = builder.Configuration.GetConnectionString("Default") 
    ?? "Server=localhost;Database=DemoApp;Trusted_Connection=true;TrustServerCertificate=true";

var app = builder.Build();

app.MapGet("/version", () => Results.Ok(new { 
    version = System.Reflection.Assembly.GetExecutingAssembly().GetName().Version?.ToString(),
    appVersion = ThisAssembly.AssemblyFileVersion
}));

app.MapGet("/products", async () => {
    var products = new List<object>();
    using var conn = new SqlConnection(connString);
    await conn.OpenAsync();
    using var cmd = new SqlCommand("SELECT Id, Name, Price FROM Products", conn);
    using var reader = await cmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
        products.Add(new { Id = reader.GetInt32(0), Name = reader.GetString(1), Price = reader.GetDecimal(2) });
    return Results.Ok(products);
});

app.Run();
