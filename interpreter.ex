defmodule Interpreter do
    
    @moduledoc """
    Elixir meta-interpreter.
    """


end

defmodule Eager do

    @moduledoc """
    An Eager implementation of evaluation of expressions.
    """

    @doc """
    Evaluate an expression in the provided environment.
    May result in an error if an expression is not evaluatable in given environment.
    """
    def eval_expr(_, {:atm, id}) do
        {:ok, id}
    end
    def eval_expr([], {:var, id}) do
        :error
    end
    def eval_expr(env, {:var, id}) do
        case Env.lookup(env, id) do
            :not_found ->
                :error
            {:ok, struct} ->
                {:ok, struct}
        end
    end
    def eval_expr(env, {:cons, a, b}) do
        case eval_expr(env, a) do
            :error ->
                :error
            {:ok, structA} ->
                case eval_expr(env, b) do
                    :error ->
                        :error
                    {:ok, structB} ->
                        {:ok, {structA, structB}}
                end
        end
    end

    @doc """
    Evaluate a pattern match in the provided environment.
    May result in a fail.
    """
    def eval_match(env, {:atm, atomId}, struct) do
        if atomId == struct do
            {:ok, env}
        else
            :fail
        end
    end
    def eval_match(env, :ignore, _) do
        {:ok, env}
    end
    def eval_match(env, {:var, id}, struct) do
        case Env.lookup(env, id) do
            :not_found ->
                {:ok, Env.add(env, id, struct)}
            {:ok, ^struct} ->
                {:ok, env}
            {:ok, _} ->
                :fail
        end
    end
    def eval_match(env, {:cons, head, tail}, {structHead, structTail}) do
        case eval_match(env, head, structHead) do
            :fail ->
                :fail
            {:ok, env} ->
                eval_match(env, tail, structTail)
        end
    end
    def eval_match(_, _, _), do: :fail
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
                :error
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
        :not_found
    end
    def lookup([{envId, envStruct} | rest], id) do
        case strcmp(envId, id) do
            0 ->
                {:ok, envStruct}
            x when x > 0 ->
                :not_found
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
        remove(remove(env, id), rest)
    end
    def remove(env, []) do
        env
    end

    @doc """
    Help function that compares 2 strings.
    """
    def strcmp([ah | at], [bh | bt]) do
        dif = ah - bh
        if dif == 0 do
            strcmp(at, bt)
        else
            dif
        end
    end
    def strcmp([], [bh | bt]), do: -bh
    def strcmp([ah | at], []), do: ah
    def strcmp([], []), do: 0
end