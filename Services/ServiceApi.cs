using BIA.Data;
using BIA.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;

namespace BIA.Services
{

    public class ServiceApi : IServiceApi
    {
        private readonly MeuDbContext _context;

        public ServiceApi(MeuDbContext context)
        {
            _context = context;
        }

        public async Task<List<Tarefa>> GetAllAsync()
        {
            try
            {
                var tarefas = await _context.Tarefas.ToListAsync();
                return tarefas;
            }
            catch
            {
                throw;
            }


        }

        [HttpPost]
        public async Task PostTarefa(Tarefa tarefa)
        {
            try
            {
                _context.Tarefas.Add(tarefa);
                await _context.SaveChangesAsync();
            }
            catch
            {
                throw;
            }
        }


        [HttpDelete("{id}")]
        public async Task DeleteTarefa(Guid id)
        {
            try
            {
                var tarefa = await _context.Tarefas.FindAsync(id);
                if (tarefa != null)
                {
                    _context.Tarefas.Remove(tarefa);
                }

                await _context.SaveChangesAsync();
            }
            catch
            {
                throw;
            }
        }
    }
}