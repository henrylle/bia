using BIA.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

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
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Tarefa>(builder =>
            {
                builder.ToTable("Tarefas");

                builder.HasKey(p => p.Id).HasName("uuid");

                builder.Property(p => p.Dia_atividade);

                builder.Property(p => p.Titulo); 

                builder.Property(p => p.createdAt);

                builder.HasIndex(p => p.updatedAt);
            });
        }
        public DbSet<Tarefa> Tarefas { get; set; }
    }
    

}


