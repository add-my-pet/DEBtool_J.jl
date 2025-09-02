abstract type AbstractLoss end
abstract type AbstractLossWithMeans end

struct SymmetricBoundedLoss <: AbstractLossWithMeans end
struct SymmetricUnboundedLoss <: AbstractLossWithMeans end
struct LikaLoss <: AbstractLossWithMeans end
struct SymmetricMeanAbsoluteErrorLoss <: AbstractLoss end

# loss
# - predicted: object with mixed scalar/svector predictions
# - data: object with mixed scalar/svector (dependent) data
# - meandata: tuple with mean value of data per set
# - weights: tuple with weights for the data
function loss(lf::AbstractLoss, predicted_u, data_u, _, weights)
    # Strip all units, forcing conversions to the units in `data`
    datatuple_u = struct2vector(data_u, data_u)
    predicted = map(_ustriptodata, struct2vector(predicted_u, data_u), datatuple_u)
    data = map(ustrip, datatuple_u)
    return loss(lf, map(SVector, (data, predicted, weights))...)
end
function loss(lf::AbstractLossWithMeans, predicted_u, data_u, meandata_u, weights)
    # Strip all units, forcing conversions to the units in `data`
    datatuple_u = struct2vector(data_u, data_u)
    predictedtuple_u = struct2vector(predicted_u, data_u)
    predicted = ModelParameters.unrolled_map(_ustriptodata, predictedtuple_u, datatuple_u)
    data = ModelParameters.unrolled_map(ustrip, datatuple_u)
    meanpredicted = ModelParameters.unrolled_map(_ustriptodata, struct2means(predicted_u, data_u), meandata_u)
    meandata = map(ustrip, meandata_u)
    return loss(lf, ModelParameters.unrolled_map(SVector, (data, meandata, predicted, meanpredicted, weights))...)
end
# Loss formulations
loss(::SymmetricBoundedLoss, data::SVector, meandata::SVector, predicted::SVector, meanpredicted::SVector, weights::SVector) =
    sum(weights .* ((data .- predicted) .^ 2 ./ (meandata .^ 2 .+ meanpredicted .^ 2)))
loss(::SymmetricUnboundedLoss, data::SVector, meandata::SVector, predicted::SVector, meanpredicted::SVector, weights::SVector) =
    sum(weights .* ((data .- predicted) .^ 2 .* (1 ./ meandata .^ 2 + 1.0 ./ meanpredicted .^ 2)))
loss(::LikaLoss, data::SVector, meandata::SVector, predicted::SVector, meanpredicted::SVector, weights::SVector) =
    sum(weights .* ((data .- predicted) ./ meandata) .^ 2)
# Without means
loss(::SymmetricMeanAbsoluteErrorLoss, data::SVector, predicted::SVector, weights::SVector) =
    sum(2 .* weights .* (abs.(data .- predicted) ./ (abs.(data) .+ abs.(predicted))))

# Force conversion to the units of d when stripping p
_ustriptodata(p, d) = p isa Unitful.Quantity ? ustrip(Unitful.unit(d), p) : p
