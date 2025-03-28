module Erhvervsfrekvens_damped_trend

export state_space, model_specs

using LinearAlgebra

############# θ and μ_1 to 0 #############

function state_space(θ)
     # Unpack parameters from θ:
     # θ = [ρᵝ, ψ₁, ψ₂, μ₁, θ, η₁, η₀, σ_{ε*}, σ_{ε^c}, σ_{shortage}]
     ρᵝ         = θ[1]
     ψ₁         = θ[2]
     ψ₂         = θ[3]
     μ₁         = 0      # we deleted these below: we should clean it up 
     θ_val      = 0      # we deleted these below: we should clean it up
     η₁         = θ[4]
     η₀         = θ[5]
     σ_ε_star   = θ[6]   
     σ_ε_c      = θ[7]
     σ_shortage = θ[8]
     
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
          0.0  ρᵝ    0.0   0.0;
          0.0  0.0   ψ₁    ψ₂;
          0.0  0.0   1.0   0.0]
     
     # Intercept matrix:
     c = [ μ₁   0.0;
           0.0  0.0;
           0.0  θ_val;
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

     θ_elements = ["ρᵝ","ψ₁", "ψ₂", "η₁", "η₀", "σ_{ε*}", "σ_{ε^c}", "σ_{shortage}"]

     α_elements = ["E_t^*", "β_t", "E_t^c", "E_{t-1}^c"]
     
     θ_true = [
         0.5,        # ρᵝ 
         0.82293,   # ψ₁
         0.06414,   # ψ₂
     #    -0.44027,   # μ₁ 
     #    -3.22096,   # θ 
         0.00552,   # η₁
         0.02436,   # η₀
         0.08239,   # σ_{ε*} 
         0.34957,   # σ_{ε^c}
         0.02609    # σ_{shortage}
     ]
     
     support = [
        -1.0    2.0;    # ρᵝ  
        -1.0    2.0;    # ψ₁
        -1.0    2.0;    # ψ₂ 
     #    -10.0   10.0;   # μ₁
     #    -10.0   10.0;   # θ
        -10.0   10.0;   # η₁ 
        -10.0   10.0;   # η₀
          0.0   Inf;    # σ_{ε*}
          0.0   Inf;    # σ_{ε^c}
          0.0   Inf     # σ_{shortage}
     ]
     
     prior_distributions = ("uniform", "uniform", "uniform", "uniform", "uniform", "inverse_gamma", "inverse_gamma", "inverse_gamma")
     prior_hyperparameters = [
          -1.0    2.0;   # ρᵝ
          -1.0    2.0;   # ψ₁
          -1.0    2.0;   # ψ₂ 
     #    -10.0    10.0; # μ₁
     #    -10.0   10.0;  # θ
         -10.0    10.0;  # η₁
         -10.0    10.0;  # η₀
          1e-6   1e-6;   # σ_{ε*}
          1e-6   1e-6;   # σ_{ε^c}
          1e-6   1e-6;   # σ_{shortage}
     ]
     
     prior_info = (
         support = support,
         distributions = prior_distributions,
         parameters = prior_hyperparameters
     )
     
     return (θ_elements = θ_elements, α_elements = α_elements, θ_true = θ_true, prior_info = prior_info)
 end
 
 end  # module ErhvervsfrekvensModel
 
 
