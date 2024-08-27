using BIA.Models;
using Microsoft.EntityFrameworkCore;

namespace Bia;

public partial class BiaContext : DbContext
{
    public BiaContext()
    {
    }

    public BiaContext(DbContextOptions<BiaContext> options)
        : base(options)
    {
    }
    public virtual DbSet<Tarefa> Tarefas { get; set; }
}
