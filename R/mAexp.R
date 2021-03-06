## A hub is just a collection of experiments

setClass("MultiAssayExperiment", representation(
    experiments = "list",
    links = "list",
    sampleData = "DataFrame"))

getExperiments <- function(object) {
    .assertMultiAssayExperiment(object)
    object@experiments
}

getLinks <- function(object) {
    .assertMultiAssayExperiment(object)
    object@links
}

setMethod("show", "MultiAssayExperiment", function(object) {
    cat(sprintf("MultiAssayExperiment with\n %s experiments\n  %s samples\nUser-defined tags:\n",
                length(getExperiments(object)), ncol(object)))
    for(ii in seq(along = getExperiments(object))) {
        massay:::.short_print_Experiment(getExperiments(object)[[ii]]) 
    }
})

setMethod("colData", "MultiAssayExperiment", function(x) {
    x@sampleData
})

getSampleData <- function(object) {
    object@sampleData
}
              
setMethod("ncol", "MultiAssayExperiment", function(x) {
    nrow(colData(x))
})

setMethod("sampleNames", "MultiAssayExperiment", function(object) {
    rownames(colData(object))
})

setMethod("getTag", "MultiAssayExperiment", function(object, i) {
    if(missing(i))
        sapply(getExperiments(object), slot, "tag")
    else
        getTag(getExperiments(object)[[i]])
})

loadExperiments <- function(mAexp) {
    .assertMultiAssayExperiment(mAexp)
    obj <- lapply(getExperiments(mAexp), loadExperiment)
    names(obj) <- getTag(mAexp)
    mAexp@experiments <- obj
    mAexp
}


## Subsetting / Selecting      
          
subsetBySample <- function(object, j, drop = FALSE) {
    .assertMultiAssayExperiment(object)
    if(is.numeric(j)) {
        j <- sampleNames(object)[j]
    }
    object@experiments <- lapply(getExperiments(object), function(oo) {
        jj <- j[j %in% sampleNames(oo)]
        oo <- oo[,jj,drop = drop]
        oo
    })
    object@sampleData <- object@sampleData[j,]
    object
}

subsetByExperiment <- function(object, i) {
    massay:::.assertMultiAssayExperiment(object)
    if(missing(i)) return(object)
    if(is.character(i)) {
        i <- match(i, getTag(object))
    }
    ## FIXME: links needs to be subsetted
    ## FIXME: should we subset masterSampleData?
    new("MultiAssayExperiment", experiments = getExperiments(object)[i],
        links = object@links, sampleData = object@sampleData)
}

setMethod("getExperiment", "MultiAssayExperiment",
          function(object, i, ...) {
              if(is.character(i)) {
                  i <- match(i, getTag(object))
              }
              massay:::.assertScalar(i)
              getExperiment(getExperiments(object)[[i]])
          })

