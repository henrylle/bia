import React, { useState } from "react";
import { format } from "date-fns";
import { ptBR } from "date-fns/locale";
import { CalendarIcon, X } from "lucide-react";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";
import { Calendar } from "./ui/calendar";
import { cn } from "../lib/utils";
import Modal from "./Modal";

const AddTask = ({ onAdd }) => {
  const [titulo, setTitulo] = useState("");
  const [dia, setDia] = useState(null);
  const [importante, setImportante] = useState(false);
  const [showModal, setShowModal] = useState(false);
  const [isCalendarOpen, setIsCalendarOpen] = useState(false);

  const onSubmit = (e) => {
    e.preventDefault();

    if (!titulo.trim()) {
      setShowModal(true);
      return;
    }

    const formatDateToString = (date) => {
      if (!date) return new Date().toLocaleDateString('pt-BR');
      return date.toLocaleDateString('pt-BR');
    };

    onAdd({
      titulo: titulo.trim(),
      dia_atividade: formatDateToString(dia),
      importante
    });

    setTitulo("");
    setDia(null);
    setImportante(false);
  };

  const handleSelectDate = (date) => {
    setDia(date ?? null);
    setIsCalendarOpen(false);
  };

  const handleClearDate = (e) => {
    e.stopPropagation();
    setDia(null);
  };

  return (
    <form className="add-form" onSubmit={onSubmit}>
      <div className="form-control">
        <label>Tarefa</label>
        <input
          type="text"
          placeholder="O que você precisa fazer?"
          value={titulo}
          onChange={(e) => setTitulo(e.target.value)}
        />
      </div>

      <div className="form-control">
        <label>Data/Prazo</label>
        <Popover open={isCalendarOpen} onOpenChange={setIsCalendarOpen}>
          <PopoverTrigger asChild>
            <button
              type="button"
              className={cn(
                "flex h-9 w-full items-center justify-between rounded-md border border-input bg-background px-3 py-2 text-sm shadow-sm transition-colors hover:bg-accent hover:text-accent-foreground focus:outline-none focus:ring-1 focus:ring-ring",
                !dia && "text-muted-foreground"
              )}
            >
              <span className="flex items-center gap-2">
                <CalendarIcon className="h-4 w-4 shrink-0 opacity-50" />
                {dia ? format(dia, "dd/MM/yyyy", { locale: ptBR }) : "Quando?"}
              </span>
              {dia && (
                <X
                  className="h-4 w-4 shrink-0 opacity-50 hover:opacity-100"
                  onClick={handleClearDate}
                />
              )}
            </button>
          </PopoverTrigger>
          <PopoverContent className="w-auto p-0" align="start">
            <Calendar
              mode="single"
              selected={dia}
              onSelect={handleSelectDate}
              locale={ptBR}
              captionLayout="dropdown"
              startMonth={new Date(new Date().getFullYear() - 14, 0)}
              endMonth={new Date(new Date().getFullYear() + 1, 11)}
              autoFocus
            />
            {dia && (
              <div className="border-t p-2">
                <button
                  type="button"
                  className="w-full rounded-md px-2 py-1.5 text-sm text-muted-foreground hover:bg-accent hover:text-accent-foreground"
                  onClick={() => handleSelectDate(null)}
                >
                  Limpar data
                </button>
              </div>
            )}
          </PopoverContent>
        </Popover>
      </div>

      <div className="form-control-check">
        <input
          type="checkbox"
          id="importante"
          checked={importante}
          onChange={(e) => setImportante(e.target.checked)}
        />
        <label htmlFor="importante">Importante</label>
      </div>

      <button type="submit" className="btn btn-block success">
        Add New Task
      </button>

      <Modal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        title="Campo obrigatório"
        message="Por favor, adicione uma descrição para a tarefa"
        type="warning"
      />
    </form>
  );
};

export default AddTask;
