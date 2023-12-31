#' Coefficient of Variation
#' @title  cv_estimation
#'
#' @param dataC A dataset a data frame with feature variables to be used
#' @param lab_replicates A numeric value indicating the number of lab replicates
#' @param sampleID_var A character string containing the name of the sample 
#' identifier variable. Default set to 'sampleID'
#' @param antigen_var A character string containing the name of the 
#' features/protein variable. Default to 'antigen'
#' @param replicate_var A character string containing the name of the replicate
#'  variable. Default to 'replicate'
#' @param mfi_var A character string containing the name of the variable with 
#' MFI value.Assuming background correction is done already.
#' Default to 'FMedianBG_correct'
#' @param cv_cut_off Optional value indicating the cut off of flagging CV's. 
#' Default set at 20.
#' @description A function to calculate the CV for the technical lab replicates.
#'  The default values are set as per the object names generated by machine
#' @import dplyr tidyr
#' @importFrom  rlang sym
#' @importFrom tidyr gather spread
#' @return A data frame where CV's of the replicates have been calculated
#' @export
#'
#' @examples
#' dataC <- readr::read_csv(system.file("extdata", 
#' "dataC.csv", package="protGear"))
#' ## this file has 3 lab replicates and the default names
#' cv_estimation(dataC  ,lab_replicates=3)
cv_estimation <-
  function(dataC  ,
           lab_replicates ,
           sampleID_var = 'sampleID',
           antigen_var = 'antigen' ,
           replicate_var = 'replicate' ,
           mfi_var = 'FMedianBG_correct' ,
           cv_cut_off = 20) {
    if (lab_replicates == 1) {
      dataC <- dataC %>%
        dplyr::filter(
          !grepl(
            '^[Ll][Aa][Nn][Dd][Mm][Aa][Rr][Kk]|^[Bb][Uu][Ff][Ff][Ee][Rr]',
            !!antigen_var
          )
        )   %>%
        filter(replicate <= lab_replicates)

      # combine Name and replicate
      #tidyr::unite(col=antigen,antigen,replicate)
      # dataC <- dataC %>%
      #   dplyr::select(sampleID,sample_array_ID, 
      #antigen,iden,FMedianBG_correct)
      ## get the name of the file
      iden <- unique(dataC$iden)
      # pick the values after the last underscore
      ## to get the replicate
      #dataC$replicate <- sub(".*_(.*)", "\\1", dataC$antigen)

      ## create a wide data to
      if (length(unique(dataC$replicate)) > lab_replicates)  {
        try(stop("Some antigens seems to be repeated in a mini array for", iden) 
            , outFile = stdout())
        error_replicates(iden)
      }

    } else if (lab_replicates > 1) {
      ## Exclude the land mark and Buffer
      dataC <- dataC %>%
        dplyr::filter(
          !grepl(
            '^[Ll][Aa][Nn][Dd][Mm][Aa][Rr][Kk]| ^[Bb][Uu][Ff][Ff][Ee][Rr]',
            !!antigen_var
          )
        )   %>%
        dplyr::filter(!!sym(replicate_var) <= lab_replicates)

      #combine Name and replicate
      #tidyr::unite(col=antigen,antigen,replicate)

      ## get the name of the file
      iden <- unique(dataC$iden)
      # pick the values after the last underscore
      ## to get the replicate
      # dataC$replicate <- sub(".*_(.*)", "\\1", dataC$antigen)
      ### pick the nname of the antigen
      ## values until the last underscore
      #dataC$antigen <- sub("\\_[^\\_]*$" , "", dataC$antigen)

      ## create a wide data to

      if (length(unique(dataC$replicate)) > lab_replicates)  {
        try(stop("The replicates per antigen per sample are more than
                 expected for ",
                 iden) , outFile = stdout())
        error_replicates(iden)
      } else
        (warning("The replicates are as expected per sample per antigen"))


      ## reshaping the data
      Data3 <- dataC %>%
        dplyr::select(contains('iden'),
                      contains('sample_array_ID'),
                      !!sampleID_var, !!mfi_var,
                      !!replicate_var,!!antigen_var) %>%
        spread(replicate, FMedianBG_correct)


      ### group the antigens and calculate their CV values
      ## the CV values > 20, get the minimum mean of each of the two mfi values
      #and use it to calculate CV
      ## select the one with lowest CV
      dataC <- dataC %>%
        dplyr::group_by_at(c(antigen_var,sampleID_var)) %>%
        ###mean and then for each grouping of 2
        summarize(meanX=mean(get(mfi_var) , na.rm=TRUE),
                  meanX2_X3=mean(get(mfi_var)[-1] , na.rm=TRUE),
                  meanX1_X3=mean(get(mfi_var)[-2] , na.rm=TRUE),
                  meanX1_X2=mean(get(mfi_var)[-3] , na.rm=TRUE),
                  ###standard deviation and then for each grouping of 2
                  sdX=round(sd(get(mfi_var) , na.rm=TRUE),2),
                  sdX2_X3=round(sd(get(mfi_var)[-1] , na.rm=TRUE),2),
                  sdX1_X3=round(sd(get(mfi_var)[-2] , na.rm=TRUE),2),
                  sdX1_X2=round(sd(get(mfi_var)[-3] , na.rm=TRUE),2),
                  ### cv
                  CVX=(round(sdX/meanX,4))*100 ,
                  CVX2_X3=(round(sdX2_X3/meanX2_X3,4))*100 ,
                  CVX1_X3=(round(sdX1_X3/meanX1_X3,4))*100 ,
                  CVX1_X2=(round(sdX1_X2/meanX1_X2,4))*100) %>%
        mutate(cvCat_all = ifelse(CVX>=0 & CVX<=cv_cut_off ,
                                  paste0("CV <= ",cv_cut_off),
                                  ifelse(CVX >cv_cut_off & CVX <101,
                                         paste0("CV > ",cv_cut_off),
                                         "Others")))   %>%
        mutate(cvSelected_all = ifelse(CVX>=0 & CVX<=cv_cut_off , CVX,
                                       ifelse(CVX >cv_cut_off | CVX<=0 ,
                                              pmin(CVX2_X3, CVX1_X3,CVX1_X2 ,
                                                   na.rm = TRUE),NA)))
      dataC <- dataC %>%
        left_join(Data3, by=c(antigen_var,sampleID_var)) %>%
        select(antigen, sampleID, sample_array_ID,everything())
    }
    return(dataC)
  }


#' Select set of replicates with the best CV
#' @title best CV estimation
#'
#' @param dataCV A data frame
#' @param slide_id A character string containing the identifier of the data
#'  frame variable.
#' @param cv_cut_off a numeric value for the CV cut off. Should be between 0-100
#' @param lab_replicates A numeric value indicating the 
#' number of lab replicates.
#'
#' @description A function to select the best CV by combining the replicates in 
#' duplicates. The function has been build for up to to 3 replicates so far
#' @import dplyr tidyr
#' @importFrom tidyr gather spread
#' @importFrom dplyr mutate select
#' @importFrom readr read_csv
#' @importFrom  plyr .
#' @return A data frame with the best CV's estimated
#' @export
#'
#' @examples
#' dataC <- readr::read_csv(system.file("extdata",
#'  "dataC.csv", package="protGear"))
#' ## this file has 3 lab replicates and the default names
#' dataCV <- cv_estimation(dataC  ,lab_replicates=3)
#' best_CV_estimation(dataCV,slide_id = "iden", lab_replicates = 3,
#'  cv_cut_off = 20)
best_CV_estimation <-
  function(dataCV,
           slide_id,
           lab_replicates ,
           cv_cut_off) {
    if (lab_replicates > 1) {
      ### Get the mean that corresponds to the lowest CV
      iden <- unique(dataCV[[slide_id]])
      data_best_CV <- as.data.frame(dataCV)

      ## changing NaN values to 0 to facilitate computation
      is.nan.data.frame <-
        function(x)
          do.call(cbind, lapply(x, is.nan))
      data_best_CV[is.nan.data.frame(data_best_CV)] <- 0

      ## get the minumum cv and put the value of the as a string variable
      ## ie CVX3 selected meanX3 value will be created
      ## might bring issues here if the subtraction has a NA or its missing for
     # the prescan
      data_best_CV <- data_best_CV %>%
        mutate(x = colnames(.[, c("CVX2_X3", "CVX1_X3", "CVX1_X2")])
               [apply(.[, c("CVX2_X3", "CVX1_X3", "CVX1_X2")], 1, 
                      which.min)])  %>%
        dplyr::mutate(xbar = paste0("meanX", gsub("CVX", "", x)))

## get the actual value of the mean that corresponds to that
#http://stackoverflow.com/questions/43762869/
      #get-row-value-corresponding-to-a-column-name
      data_best_CV <- data_best_CV %>%
        mutate(row = 1:n()) %>%
        # select(-c(`1`,`2`,`3`,iden)) %>%
        gather(prop, val, meanX1_X2:meanX2_X3) %>%
        group_by(row) %>%
        mutate(selected = val[xbar == prop]) %>%
        spread(prop, val) %>% dplyr::select(-row)


      ##create the final selected mean in the data set
      data_best_CV <-  data_best_CV %>%
        mutate(
          meanSelected = ifelse(
            CVX >= 0 & CVX <= cv_cut_off ,
            meanX,
            ifelse((CVX > cv_cut_off &
                      CVX < 101)  | CVX <= 0 , selected, NA)
          ),
          mean_best_CV = selected
        ) %>%
        dplyr::select(-xbar, -selected)
      data_best_CV <-  data_best_CV %>%
        mutate(
          best_CV = pmin(CVX2_X3, CVX1_X3, CVX1_X2, na.rm = TRUE) ,
          best_CV_cat  = ifelse(
            best_CV >= 0 & best_CV <= cv_cut_off ,
            paste0("CV <= ", cv_cut_off),
            ifelse(
              best_CV > cv_cut_off &
                best_CV < 101,
              paste0("CV > ", cv_cut_off),
              "Others"
            )
          )
        )

    } else if (lab_replicates == 1) {
      ### Get the mean that corresponds to the lowest CV
      iden <- unique(dataCV[[slide_id]])
      data_best_CV <- as.data.frame(dataCV)

      ## changing NaN values to 0 to facilitate computation
      is.nan.data.frame <-
        function(x)
          do.call(cbind, lapply(x, is.nan))
      data_best_CV[is.nan.data.frame(data_best_CV)] <- 0

      ### generate the variabrl
      data_best_CV <- data_best_CV %>%
        mutate(mean_best_CV = FMedianBG_correct)
    }

    ## return the dataset of interest
    return(data_best_CV)
  }
#'
#'
#'         \\\_End_Function_\\\         #
#'
#'




#' Subtract the purification TAG data
#' @title tag_subtract
#'
#' @param tag_antigens A character vector with the names of proteins or antigens
#'  used as TAG.
#' @param mean_best_CV_var A character string containing the identifier of the 
#' variable with the MFI values.
#' @param dataC_mfi A dataframe
#' @param sampleID_var A character string containing the name of the sample 
#' identifier variable. Default set to 'sampleID'
#' @param antigen_var A character string containing the name of the
#'  features/protein variable. Default to 'antigen'
#' @param batch_vars A list of characters identifying variables in dataC_mfi 
#' for indicating  batch.
#' @param tag_file A data frame with variables \code{antigen, TAG, TAG_name } 
#' to show the TAG for the different antigens or proteins in dataC_mfi
#' @import dplyr tidyr
#' @importFrom tidyr gather spread
#' @importFrom rlang := !! UQ
#' @return A data frame of TAG values subtracted
#' @export
#'
#' @examples
#' tag_file <- readr::read_csv(system.file("extdata", "TAG_antigens.csv", 
#' package="protGear"))
#' tag_antigens <- c("CD4TAG", "GST", "MBP")
#' batch_vars <- list(machine = "m1", day = "0520")
#' dataC <- readr::read_csv(system.file("extdata", "dataC.csv",
#'  package="protGear"))
#' ## this file has 3 lab replicates and the default names
#' dataCV <- cv_estimation(dataC  ,lab_replicates=3)
#' dataCV_best2 <- best_CV_estimation(dataCV,slide_id = "iden", 
#' lab_replicates = 3, cv_cut_off = 20)
#' tag_subtract(dataCV_best2,tag_antigens=tag_antigens, 
#' mean_best_CV_var="mean_best_CV",
#'  tag_file = tag_file,antigen_var = "antigen", batch_vars = batch_vars)
tag_subtract <-
  function(dataC_mfi,
           tag_antigens,
           mean_best_CV_var,
           tag_file,
           batch_vars,
           sampleID_var = 'sampleID',
           antigen_var = 'antigen') {
    mean_best_CV_var <-  rlang::sym(paste0(mean_best_CV_var))
    sampleID_var <-  rlang::sym(paste0(sampleID_var))
    antigen_var <-  rlang::sym(paste0(antigen_var))
    ## remove the tag for the data

    dataC_mfi_tags <- dataC_mfi %>%
      dplyr::filter(UQ(antigen_var) %in% tag_antigens) %>%
      ungroup() %>%
      dplyr::select(!!sampleID_var,!!antigen_var ,!!mean_best_CV_var) %>%
      ##change all the negative TAG values to zero
      mutate(!!mean_best_CV_var := ifelse(!!mean_best_CV_var < 0, 
                                          0, !!mean_best_CV_var)) %>%
      spread(!!antigen_var ,!!mean_best_CV_var)

    ## join the data with the fused antigen name for subtraction
    dataC_mfi <-
      left_join(dataC_mfi , tag_file, by = paste(antigen_var))

    dataC_mfi <- dataC_mfi %>% ungroup() %>%
      dplyr::select(
        !!sampleID_var ,
        contains('sample_array_ID'),
        !!sampleID_var ,
        TAG,
        everything() ,
        -row
      )
    dataC_mfi <- dataC_mfi %>% ungroup() %>%
      left_join(x = dataC_mfi ,
                y = dataC_mfi_tags ,
                by = paste(sampleID_var)) %>%
      mutate(TAG_mfi = NA)
    vars_in <- names(dataC_mfi)


    ## mutate the tag_mfi variable
    for (i in tag_antigens) {
      tag_var <- rlang::sym(paste0(i))
      dataC_mfi <- dataC_mfi %>%
        mutate(TAG_mfi = ifelse(TAG_name == i &
                                  is.na(TAG_mfi), !!tag_var, TAG_mfi))
    }

    ## subtract the TAG values depending on the TAG of
    mean_best_CV_tag_var <-
      rlang::sym(paste0(mean_best_CV_var, "_tag"))
    dataC_mfi <- dataC_mfi %>%
      mutate(TAG_mfi = ifelse(is.na(TAG_mfi), 0, TAG_mfi)) %>%
      mutate(!!mean_best_CV_tag_var := !!mean_best_CV_var - TAG_mfi)  %>%
      dplyr::select(c(vars_in, paste(mean_best_CV_tag_var))) %>%
      ## add the batch variables to the data
      mutate(machine = batch_vars[["machine"]] , day = batch_vars[["day"]])
    return(dataC_mfi)
  }
