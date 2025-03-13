module state_space_model

export simulate_data, standardize_data, get_model_spec, get_state_space

include("import_packages.jl")


# Import the models
using Main.WaveCycleStochasticDriftModel
using Main.WaveCycleStochasticDriftNoNoiseModel
using Main.ErhvervsfrekvensModel
using Main.Erhvervsfrekvens_støj
using Main.Erhvervsfrekvens_drift
using Main.Erhvervsfrekvens_drift_noise
using Main.Erhvervsfrekvens_damped_trend



#########################
# Get Model Specification
#########################

function get_model_spec(model::String)
    if model == "wave cycle stochastic drift"
        return WaveCycleStochasticDriftModel.model_specs()
    elseif model == "wave cycle stochastic drift no noise"
        return WaveCycleStochasticDriftNoNoiseModel.model_specs()
    elseif model == "ErhvervsfrekvensModel"
        return ErhvervsfrekvensModel.model_specs()
    elseif model == "Erhvervsfrekvens_støj"
        return Erhvervsfrekvens_støj.model_specs()
    elseif model == "Erhvervsfrekvens_drift"
        return Erhvervsfrekvens_drift.model_specs()
    elseif model == "Erhvervsfrekvens_drift_noise"
        return Erhvervsfrekvens_drift_noise.model_specs()
    elseif model == "Erhvervsfrekvens_damped_trend"
        return Erhvervsfrekvens_damped_trend.model_specs()
    else
        error("Unknown model specification: $model")
    end
end

#########################
# Get State-Space Matrices
#########################

function get_state_space(model::String, θ; cycle_order = 1)
    if model == "wave cycle stochastic drift"
        return WaveCycleStochasticDriftModel.state_space(θ, cycle_order)
    elseif model == "wave cycle stochastic drift no noise"
        return WaveCycleStochasticDriftNoNoiseModel.state_space(θ, cycle_order)
    elseif model == "ErhvervsfrekvensModel"
        return ErhvervsfrekvensModel.state_space(θ)
    elseif model == "Erhvervsfrekvens_støj"
        return Erhvervsfrekvens_støj.state_space(θ)
    elseif model == "Erhvervsfrekvens_drift"
        return Erhvervsfrekvens_drift.state_space(θ)
    elseif model == "Erhvervsfrekvens_drift_noise"
        return Erhvervsfrekvens_drift_noise.state_space(θ)
    elseif model == "Erhvervsfrekvens_damped_trend"
        return Erhvervsfrekvens_damped_trend.state_space(θ)
    else
        error("Unknown model specification: $model")
    end
end

#########################
# Simulation Function
#########################

function rand_draw(dim, Σ; rng=Random.GLOBAL_RNG)
    draws = zeros(dim)
    nonzero_variances = findall(i -> abs(Σ[i,i]) > 0, 1:dim)
    if !isempty(nonzero_variances)
        Σ_sub = Σ[nonzero_variances, nonzero_variances]
        draws[nonzero_variances] = rand(rng, MvNormal(zeros(length(nonzero_variances)), Σ_sub))
    end
    return draws
end

function simulate_data(model, θ, n_obs; X = nothing)
    # Retrieve system matrices from the state-space function.
    Z, H, d, T, R, Q, c = get_state_space(model, θ)
    println("Z: ", Z)
    println("H: ", H)
    println("d: ", d)
    println("T: ", T)
    println("R: ", R)
    println("Q: ", Q)
    println("c: ", c)
    state_dim = size(T, 1)
    obs_dim = size(Z, 1)
    
    # Initialize arrays.
    α = zeros(state_dim, n_obs)
    y = zeros(obs_dim, n_obs)
    
    α_current = zeros(state_dim)
    for t in 1:n_obs
        # simulate state evolution:
        if X !== nothing 
            α_current = c*X[:,t] + T * α_current + R * rand(MvNormal(zeros(size(Q,1)), Q))
        else
            α_current = c + T * α_current + R * rand(MvNormal(zeros(size(Q,1)), Q))
        end
        α[:, t] = α_current
        # simulate measurement:
        ϵ = rand_draw(obs_dim, H)
        y[:, t] = d + Z * α_current + ϵ
    end
    
    return y, α
end

#########################
# Standardise (First differences of) Data 
#########################

function standardize_data(y)
    n_vars, n_obs = size(y)
    y_std = similar(y)
    σy = zeros(n_vars)
    
    # Loop over each variable (row)
    for j in 1:n_vars
        s = std(diff(y[j, :]))
        σy[j] = s
        y_std[j, :] = y[j, :] ./ s
    end
    
    return y_std, σy
end

end  # module state_space_model
