module TextAdventure

using TerminalMenus
using TOML

function parsecode(code)
    exprs = Meta.parse(join(["quote", code, "end"], ";")).args[1].args
    return filter(x -> !(x isa LineNumberNode), exprs)
end

function evalcode(code)
    for expr in parsecode(code)
        eval(expr)
    end
end

function simple_interpolate(text)
    return replace(text, r"\$\w+" => x -> eval(Meta.parse(x[2:end])))
end

function read(storyfile)
    story = TOML.parsefile(storyfile)
    current = story["start"]

    while true
        if "code" ∈ keys(current)
            evalcode(current["code"])
        end

        if "text" ∈ keys(current)
            println(simple_interpolate(current["text"]))
        end

        if "next" ∉ keys(current)
            break
        end

        nexts = current["next"]

        menu = RadioMenu([next["prompt"] for next in nexts])
        choice = request("Make a selection: ", menu)
        
        println()

        if "code" in keys(nexts[choice])
            evalcode(nexts[choice]["code"])
        end
        
        jump = nexts[choice]["jump"]
        current = story[jump]
    end
end

end # module
