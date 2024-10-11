using BIA.Models;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace BIA.Services
{
   public interface IServiceApi
    {
        Task<List<Tarefa>> GetAllAsync();
        Task PostTarefa(Tarefa tarefa);
        Task DeleteTarefa(Guid id);
        Task<Tarefa> AlternarImportante(Guid id);
    }
}
