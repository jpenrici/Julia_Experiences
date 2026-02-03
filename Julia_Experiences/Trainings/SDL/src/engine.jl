# engine.jl
# References:
#   https://wiki.libsdl.org/SDL2/FrontPage
#   https://github.com/JuliaMultimedia/SimpleDirectMediaLayer.jl

mutable struct PaintState
    brush_color::RGB{Float64}
    bg_color::RGB{Float64}
    is_drawing::Bool
    last_pos::Vector{Int32} # [x, y]
    quit::Bool

    PaintState() = new(RGB(1.0, 1.0, 1.0), RGB(0.1, 0.1, 0.1), false, Int32[0, 0], false)
end


function set_sdl_color(renderer, color::RGB)
    r = round(UInt8, color.r * 255)
    g = round(UInt8, color.g * 255)
    b = round(UInt8, color.b * 255)
    SDL_SetRenderDrawColor(renderer, r, g, b, 255)
end


function handle_event!(event::SDL_Event, state::PaintState)
    t = event.type

    if t == SDL_QUIT
        state.quit = true

    elseif t == SDL_MOUSEBUTTONDOWN
        state.is_drawing = true
        state.last_pos = [Int32(event.button.x), Int32(event.button.y)]

    elseif t == SDL_MOUSEBUTTONUP
        state.is_drawing = false

    elseif t == SDL_MOUSEMOTION && state.is_drawing
        return :draw

    elseif t == SDL_KEYDOWN
        scan_code = event.key.keysym.scancode
        if scan_code == SDL_SCANCODE_ESCAPE
            state.quit = true
        elseif scan_code ==  SDL_SCANCODE_C # Clear
            return :clear
        end
    end

    return :none
end


function run_app()
    @assert SDL_Init(SDL_INIT_VIDEO) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"

    win = SDL_CreateWindow("Julia Mini Paint",
                           SDL_WINDOWPOS_CENTERED,
                           SDL_WINDOWPOS_CENTERED,
                           800, 600,
                           SDL_WINDOW_SHOWN)
    SDL_SetWindowResizable(win, SDL_TRUE)

    renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)

    state = PaintState()
    event_ref = Ref{SDL_Event}()

    set_sdl_color(renderer, state.bg_color)
    SDL_RenderClear(renderer)

    try
        while !state.quit
            while SDL_PollEvent(event_ref) != 0
                evt = event_ref[]
                action = handle_event!(evt, state)

                if action == :draw
                    set_sdl_color(renderer, state.brush_color)
                    SDL_RenderDrawLine(renderer,
                                       state.last_pos[1], state.last_pos[2],
                                       evt.motion.x, evt.motion.y)
                    state.last_pos = [Int32(evt.motion.x), Int32(evt.motion.y)]
                end

                if action == :clear
                    set_sdl_color(renderer, state.bg_color)
                    SDL_RenderClear(renderer)
                end
            end
            SDL_RenderPresent(renderer)
            SDL_Delay(1000 ÷ 60)
        end
    finally
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end
