using BIA.Models;

namespace BIA.Services
{
   public interface IServiceApi
    {
        Task<List<Tarefa>> GetAllAsync();
        Task PostTarefa(Tarefa tarefa);
        Task DeleteTarefa(Guid id);
    }
}
