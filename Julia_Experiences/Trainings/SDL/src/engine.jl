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

const COLOR_PALETTE = Dict(
    SDL_SCANCODE_1 => RGB(1.0, 0.0, 0.0), # Red
    SDL_SCANCODE_2 => RGB(0.0, 1.0, 0.0), # Green
    SDL_SCANCODE_3 => RGB(0.0, 0.0, 1.0), # Blue
    SDL_SCANCODE_4 => RGB(1.0, 1.0, 0.0), # Yellow
    SDL_SCANCODE_0 => RGB(1.0, 1.0, 1.0)  # White
    )

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
            elseif haskey(COLOR_PALETTE, scan_code)
                state.brush_color = COLOR_PALETTE[scan_code]
            end
        end

    return :none
end


function run_app()
    @assert SDL_Init(SDL_INIT_VIDEO) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"

    win_width = 800
    win_height = 600

    win = SDL_CreateWindow("Julia Mini Paint",
                           SDL_WINDOWPOS_CENTERED,
                           SDL_WINDOWPOS_CENTERED,
                           win_width, win_height,
                           SDL_WINDOW_SHOWN)
    SDL_SetWindowResizable(win, SDL_TRUE)

    renderer = SDL_CreateRenderer(win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)

    state = PaintState()
    event_ref = Ref{SDL_Event}()

    canvas = SDL_CreateTexture(renderer,
                               SDL_PIXELFORMAT_RGBA8888,
                               SDL_TEXTUREACCESS_TARGET,
                               win_width, win_height)

    SDL_SetRenderTarget(renderer, canvas)
    set_sdl_color(renderer, state.bg_color)
    SDL_RenderClear(renderer)
    SDL_SetRenderTarget(renderer, C_NULL)

    try
        while !state.quit
            while SDL_PollEvent(event_ref) != 0
                evt = event_ref[]
                action = handle_event!(evt, state)

                if action == :draw
                    SDL_SetRenderTarget(renderer, canvas)
                    set_sdl_color(renderer, state.brush_color)
                    SDL_RenderDrawLine(renderer,
                                       state.last_pos[1], state.last_pos[2],
                                       evt.motion.x, evt.motion.y)
                    state.last_pos = [Int32(evt.motion.x), Int32(evt.motion.y)]
                    SDL_SetRenderTarget(renderer, C_NULL)
                end

                if action == :clear
                    SDL_SetRenderTarget(renderer, canvas)
                    set_sdl_color(renderer, state.bg_color)
                    SDL_RenderClear(renderer)
                    SDL_SetRenderTarget(renderer, C_NULL)
                end

            end
            SDL_RenderClear(renderer)
            SDL_RenderCopy(renderer, canvas, C_NULL, C_NULL)

            SDL_RenderPresent(renderer)
            SDL_Delay(1000 ÷ 60)

        end
    finally
        SDL_DestroyRenderer(renderer)
        SDL_DestroyWindow(win)
        SDL_Quit()
    end
end
