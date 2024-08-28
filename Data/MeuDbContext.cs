using BIA.Models;
using Microsoft.EntityFrameworkCore;

namespace BIA.Data
{
    public class MeuDbContext : DbContext
    {
        private readonly IConfiguration _configuration;

        public MeuDbContext(DbContextOptions<MeuDbContext> options, IConfiguration configuration)
            : base(options)
        {
            _configuration = configuration;
        }
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseNpgsql(_configuration.GetConnectionString("DefaultConnection"));
            }
        }
        public DbSet<Tarefa> Tarefas { get; set; }
    }
    

}


