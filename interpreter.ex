defmodule Interpreter do
    
    @moduledoc """
    Elixir meta-interpreter.
    """


end

defmodule Env do
    
    @moduledoc """
    Elixir environment library.

    An environment is a pairing of id to a value.
    Current implementation is a simple list.

    Notes from Griffone:
    Environment is passed as the first argument.
    This comes from object oriented programming, where the object reference is passed as the first argument into a function.
    """

    @doc """
    Return a new Elixir environment.
    """
    def new() do
        []
    end

    @doc """
    Insert an id-struct pair into the environment.
    """
    def add([], id, struct) do
        [{id, struct}]
    end
    def add([{envId, envStruct} | rest], id, struct) do
        case strcmp(envId, id) do
            0 ->
                :error_duplicate_id
            x when x > 0 ->
                [{id, struct}, {envId, envStruct} | rest]
            x when x < 0 ->
                [{envId, envStruct} | add(rest, id, struct)]
        end
    end

    @doc """
    Lookup an item in the environment.
    """
    def lookup([], id) do
        :error_id_not_found
    end
    def lookup([{envId, envStruct} | rest], id) do
        case strcmp(envId, id) do
            0 ->
                envStruct
            x when x > 0 ->
                :error_id_not_found
            x when x < 0 ->
                lookup(rest, id)
        end
    end

    @doc """
    Remove an element from an environment.
    """
    def remove([], id) do
        []
    end
    def remove([{envId, envStruct} | rest], id) do
        case strcmp(envId, id) do
            x when x >= 0 ->
                rest
            x when x < 0 ->
                [{envId, envStruct} | remove(rest, id)]
        end
    end
    def remove(env, [id | rest]) do
        remove(remove(id), rest)
    end
    def remove(env, []) do
        env
    end

    @doc """
    Help function that compares 2 strings.
    """
    def strcmp([ah | at], [bh | bt]) do
        dif = ah - bh
        if dif == 0
            strcmp(at, bt)
        else
            dif
        end
    end
    def strcmp([], [bh | bt]), do: -bh
    def strcmp([ah | at], []), do: ah
    def strcmp([], []), do: 0
end