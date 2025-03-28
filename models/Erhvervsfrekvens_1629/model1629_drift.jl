module model1629_drift

export state_space, model_specs

using LinearAlgebra

############# θ and μ_1 to 0 #############

function state_space(θ)
     # Unpack parameters from θ:
     # θ = [ψ₁, ψ₂, μ₁, θ, η₁, η₀, σ_{ε*}, σ_{ε^c}, σ_{shortage}]
     ψ₁         = θ[1]
     ψ₂         = θ[2]
     μ₁         = θ[3]
     μ₂         = θ[4]   
     η₁         = θ[5]
     η₀         = θ[6]
     σ_ε_star   = θ[7]   #
     σ_ε_c      = θ[8]
     σ_shortage = θ[9]
     
     # Observation equation:
     Z = [1.0   0.0   1.0   0.0;
          0.0   0.0   η₁    0.0]
     
     d = [0.0; η₀]
     
     H = [0.0        0.0;
          0.0  σ_shortage^2]
     
     # State equation:
     # New state vector: [E_t^*, β_t, E_t^c, E_{t-1}^c]
     # Transition matrix:
     T = [1.0  1.0   0.0   0.0;
          0.0  1.0   0.0   0.0;
          0.0  0.0   ψ₁    ψ₂;
          0.0  0.0   1.0   0.0]
     
     # Intercept matrix:
     c = [ μ₁   μ₂;
           0.0  0.0;
           0.0  0.0;
           0.0  0.0 ]
     
     # State noise covariance:
     Q = [σ_ε_star^2    0.0;
          0.0       σ_ε_c^2]
     
     # Map disturbances into the state equation:
     R = [0.0  0.0;
          1.0  0.0;
          0.0  1.0;
          0.0  0.0]
     
     # Diffuse initialization:
     # E_t^* and β_t are nonstationary.
     P_diffuse = zeros(4, 4)
     P_diffuse[1,1] = 1.0  # for E_t^*
     P_diffuse[2,2] = 1.0  # for β_t
     
     return Z, H, d, T, R, Q, c, P_diffuse
 end
 
 
 function model_specs()

     θ_elements = ["ψ₁", "ψ₂","μ₁","μ₂", "η₁", "η₀", "σ_{ε*}", "σ_{ε^c}", "σ_{shortage}"]

     α_elements = ["E_t^*", "β_t", "E_t^c", "E_{t-1}^c"]
     
     θ_true = [
        1.18556, # ψ1
        -0.19498, # ψ2
        0.11000, # μ1
        -0.40000, # μ2
        0.01604, # η1
        0.08047, # η0
        0.1364586, # σ_star 
        0.43152, # σ_c
        0.03070  # σ_short
    ]
    
    # Define support for each parameter:
    support = [
        -1.0    2.0;    # ψ₁
       -1.0    2.0;    # ψ₂ 
       -10.0   10.0;    # μ₁
       -10.0   10.0;    # μ₂
        -10.0    10.0;    # η₁ 
       -10.0   10.0;    # η₀
        0.0    Inf;    # σ_{ε*}
        0.0    Inf;    # σ_{ε^c}
        0.0    Inf     # σ_{shortage}
    ]
    
    prior_distributions = ("uniform", "uniform", "uniform", "uniform", "uniform", "uniform", "normal", "inverse_gamma", "inverse_gamma")
    prior_hyperparameters = [
         0.0   2.0;  # ψ₁
        -0.5   1.0;  # ψ₂
       -1.0  1.0;    # μ₁
       -10.0  10.0;  # μ₂
        -1.0   1.0;  # η₁
       -1.0  1.0;    # η₀
        # 2.0  3.0*0.08239;  # σ_star
        0.08239  0.00001;  #  # σ_star very informative prior on σ_star
        2.0  3.0*0.34957;  # σ_c
        2.0  3.0*0.02609;  # σ_shortage
        # 0.34957  0.00001;  # σ_c
        # 0.02609  0.00001   # σ_shortage
    ]

     prior_info = (
         support = support,
         distributions = prior_distributions,
         parameters = prior_hyperparameters
     )
     
     return (θ_elements = θ_elements, α_elements = α_elements, θ_true = θ_true, prior_info = prior_info)
 end
 
 end  # module ErhvervsfrekvensModel
 
 
