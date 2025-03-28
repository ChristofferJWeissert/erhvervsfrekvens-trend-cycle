module model_ledighed

export state_space, model_specs

using LinearAlgebra


function state_space(θ)
    # Unpack parameters from θ:
    # θ = [ρ, α₁, α₂, γ, η₀, η₁, β₁, β₂, β₃, β₄, σ_{ζ}, σ_{κ}, σ_{ϵ}]
    ρ      = θ[1]
    α₁     = θ[2]
    α₂     = θ[3]
    γ      = θ[4]
    η₀     = θ[5]
    η₁     = θ[6]
    β₁     = θ[7]
    β₂     = θ[8]
    β₃     = θ[9]
    β₄     = θ[10]
    σ_ζ    = θ[11]
    σ_κ    = θ[12]
    σ_ϵ    = θ[13]

    # Observation equation:
    Z = [1.0   0.0   1.0   0.0;
         0.0   0.0    γ    0.0]  

    # Measurement noise covariance
    H = [0.0      0.0;
         0.0      σ_ϵ^2]

    # Observation intercept:
    d = [0.0; 0.0]
    
    # State equation:
    T = [1.0  ρ  0.0  0.0;
         0.0  ρ  0.0  0.0;
         0.0  0.0  α₁ α₂;
         0.0  0.0  1.0  0.0]

    c = zeros(4, 7)


    D = [ 0.0   0.0   0.0   0.0   0.0   0.0   0.0 ;
          β₁    β₂    β₃    β₄    0.0   η₁    η₀  ]
    
    # State noise covariance:
    Q = [σ_ζ^2  0.0;
        0.0   σ_κ^2]


    R = [1.0 0.0;
         1.0 0.0;
         0.0 1.0;
         0.0 0.0]
    
  
    
    # Diffuse initialization: we assume the trend (first state) is nonstationary.
    P_diffuse = zeros(4, 4)
    P_diffuse[1,1] = 1.0  # Set the variance of E_t^* diffuse part.
    
    return Z, H, d, T, R, Q, c, P_diffuse, D
end


function model_specs()
    # 1. Parameter names in order
    θ_elements = [
        "ρ", "α₁", "α₂", "γ", "η₀", "η₁", 
        "β₁", "β₂", "β₃", "β₄", "σ_{ζ}", "σ_{κ}", "σ_{ϵ}"
    ]

    # 2. State variable names (adapt to your actual model states)
    α_elements = [
        "u_t^*",    # example: internal unemployment
        "Δu_t^*",    # example: cyclical part
        "u_t^c",       # ...
        "u_{t-1}^c",       # ...
    ]

    # 3. Some default or true values for each parameter (for simulation or initialization)
    #    You can adjust these based on your knowledge or guess
    θ_true = [
        0.86928,  # ρ: autoregressive coefficient for state 1 (e.g., unemployment level)
        1.538,    # α₁: AR coefficient for the cyclical component (state 2)
       -0.56704,  # α₂: second AR coefficient for the cyclical component (state 2)
       -0.19670,  # γ: coefficient for the trend state (state 4) dynamics
        0.00657,  # η₀: constant/intercept for state 1 evolution
        0.47920,  # η₁: constant/intercept for state 2 evolution
       -0.0149,   # β₁: measurement equation coefficient for exogenous effect (first part of D, row 2)
        0.17424,  # β₂: measurement equation coefficient for exogenous effect (second part of D, row 2)
        0.16337,  # β₃: measurement equation coefficient for exogenous effect (third part of D, row 2)
        0.12363,  # β₄: measurement equation coefficient for exogenous effect (fourth part of D, row 2)
        0.003,    # σ_ζ: standard deviation for noise affecting state 1 (level noise)
        0.00916,  # σ_κ: standard deviation for noise affecting the cyclical component (state 2)
        0.04995   # σ_ϵ: standard deviation for measurement (observation) noise
    ]

    # 4. Define support (lower and upper bounds) for each parameter
    #    Example: for the scale params (σ's) set [0, Inf).
    #    For the others, set some plausible range.
    support = [
        -0.99   0.99;   # ρ
        -2.0    2.0;    # α₁
        -2.0    2.0;    # α₂
        0.0     2.0;    # γ (assuming gamma is positive or in [0,2], adjust as needed)
        -5.0    5.0;    # η₀
        -5.0    5.0;    # η₁
        -5.0    5.0;    # β₁
        -5.0    5.0;    # β₂
        -5.0    5.0;    # β₃
        -5.0    5.0;    # β₄
         0.0    Inf;    # σ_{ζ}
         0.0    Inf;    # σ_{κ}
         0.0    Inf     # σ_{ϵ}
    ]

    # 5. Define prior distributions for each parameter.
    #    For example, uniform for the first 10 (structural) and inverse_gamma for the 3 scale params:
    prior_distributions = (
        "uniform",      # ρ
        "uniform",      # α₁
        "uniform",      # α₂
        "uniform",      # γ
        "uniform",      # η₀
        "uniform",      # η₁
        "uniform",      # β₁
        "uniform",      # β₂
        "uniform",      # β₃
        "uniform",      # β₄
        "inverse_gamma",# σ_{ζ}
        "inverse_gamma",# σ_{κ}
        "inverse_gamma" # σ_{ϵ}
    )

    # 6. Define hyperparameters for each prior
    #    For uniform, use (lower, upper). 
    #    For inverse_gamma, use (shape, scale).
    prior_hyperparameters = [
        -0.99  0.99;    # ρ: uniform
        -2.0   2.0;     # α₁: uniform
        -2.0   2.0;     # α₂: uniform
        0.0    2.0;     # γ: uniform
       -5.0    5.0;     # η₀: uniform
       -5.0    5.0;     # η₁: uniform
       -5.0    5.0;     # β₁: uniform
       -5.0    5.0;     # β₂: uniform
       -5.0    5.0;     # β₃: uniform
       -5.0    5.0;     # β₄: uniform
        2.0   0.001;    # σ_{ζ}: shape=2, scale=0.001 => mean=0.001 if shape=2
        2.0   0.001;    # σ_{κ}: shape=2, scale=0.001
        2.0   0.0005    # σ_{ϵ}: shape=2, scale=0.0005
    ]

    # Bundle into a named tuple
    prior_info = (
        support = support,
        distributions = prior_distributions,
        parameters = prior_hyperparameters
    )

    return (
        θ_elements = θ_elements,
        α_elements = α_elements,
        θ_true = θ_true,
        prior_info = prior_info
    )
end

end  # module model_ledighed




