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
    def eval_expr(_, {:atm, id}), do: id
    def eval_expr(env, {:var, id}) do
        case Env.lookup(env, id) do
            nil -> :error
            {id, struct} -> {:ok, struct}
        end
    end
    def eval_expr(env, {:cons, a, b}) do
        case eval_expr(env, a) do
            :error -> :error
            {:ok, structA} ->
                case eval_expr(env, b) do
                    :error -> :error
                    {:ok, structB} -> {:ok, {structA, structB}}
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

    def eval_seq(env, [{:match, left, right} | rest]) do
        case eval_expr(env, right) do
            :error ->
                :error
            {:ok, struct} ->
                vars = extract_variables(left)
                env = Env.remove(env, vars)
                
                case eval_match(env, left, struct) do
                    :fail ->
                        :error
                    {:ok, env} ->
                        eval_seq(env, rest)
                end
        end
    end
    def eval_seq(env, [exp]), do: eval_expr(env, exp)
    def eval_seq(seq), do: eval_seq([], seq)

    def extract_variables({:atm, _}), do: []
    def extract_variables({:var, id}), do: [id]
    def extract_variables({:cons, head, tail}), do: extract_variables(head) ++ extract_variables(tail)
    def extract_variables(_), do: []
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
    def new(), do: %{}

    @doc """
    Insert an id-struct pair into the environment.
    """
    def add(environment, id, structure), do: Map.put(environment, id, structure)

    @doc """
    Lookup an item in the environment.
    """
    def lookup(environment, id) do
        case Map.get(environment, id) do
            nil -> nil
            structure -> {id, structure}
        end
    end

    @doc """
    Remove every id in ids from environment
    """
    def remove(environment, ids), do: Map.drop(environment, ids)
end