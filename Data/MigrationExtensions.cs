using BIA.Data;
using Microsoft.EntityFrameworkCore;

public static class MigrationExtensions
{
    public static async Task AplicarMigrationsAsync(IHost host)
    {
        using (var scope = host.Services.CreateScope())
        {
            try
            {
                var services = scope.ServiceProvider;
                var dbContext = services.GetRequiredService<MeuDbContext>();
                await dbContext.Database.MigrateAsync();
                Console.WriteLine("Migrations ok");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erro ao executar o migrations: {ex.Message}");
            }
        }
    }
}
