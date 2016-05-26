GDC_raw_count_merge <- function( id_list="my_id_list", my_rot="no", debug=FALSE)
    
{                       
    ### MAIN ###
    ###### load the neccessary packages
    if ( is.element("matlab", installed.packages()[,1]) == FALSE ){ install.packages("matlab") }    
    library(matlab)
    
    my_ids <- flatten_list(as.list(scan(file=id_list, what="character")))

    my_keys <- list(type="character")

    # read through once to get the keys
    for ( i in 1:length(my_ids) ){
        print(paste("First read: ", i))
        my_data <- data.matrix(read.table(file=my_ids[i], row.names=1, header=TRUE, sep="\t", comment.char="", quote="", check.names=FALSE))
        my_keys <- unique( c(rownames(my_data), my_keys) )
        if(debug==TRUE){print(paste("num keys: ", length(my_keys)))}
    }

    # Matrix to collect the data on the second pass
    my_data_matrix <- matrix(NA, length(my_keys), length(my_ids))
    rownames(my_data_matrix) <- my_keys
    colnames(my_data_matrix) <- my_ids

    # Read second time to generate the data matrix
    for ( i in 1:length(my_ids) ){
        print(paste("Second read: ", i))
        my_data <- data.matrix(read.table(file=my_ids[i], row.names=1, header=TRUE, sep="\t", comment.char="", quote="", check.names=FALSE))
        my_data.list <- as.list(my_data)
        if(debug==TRUE){
            print(paste("Length list: ", length(my_data.list)))
            print(paste("Nrows data : ", length(rownames(my_data))))
        }
        names(my_data.list) <- rownames(my_data)
        for ( j in 1:length(my_data.list) ){
            if(debug==TRUE){print(paste("my key: ", my_keys[j]))}
            my_data_matrix[ my_keys[j] , my_ids[i] ] <- my_data.list[j]
        }
        rownames(my_data_matrix) <- gsub(".htseq.counts.gz", "", rownames(my_data_matrix)) # get rid of extensions leaving just the uuid (for easy metadata lookup later) 
    }

    # export the merged data
    if( identical(my_rot, "yes")==TRUE ){
        my_data_matrix <- rot90(rot90(rot90(my_data_matrix)))
    }
    fileout_name <- gsub(" ", "", paste(id_list, ".merged_data.txt"))
    export_data(my_data_matrix, fileout_name)
    
}

### SUBS ###                    
import_data <- function(file_name)
{
  data.matrix(read.table(file_name, row.names=NA, header=TRUE, sep="\t", comment.char="", quote="", check.names=FALSE))
}

export_data <- function(data_object, file_name){
    write.table(data_object, file=file_name, sep="\t", col.names = NA, row.names = TRUE, quote = FALSE, eol="\n")
}

flatten_list <- function(some_list){
    flat_list <- unlist(some_list)
    flat_list <- gsub("\r","",flat_list)
    flat_list <- gsub("\n","",flat_list)
    flat_list <- gsub("\t","",flat_list)
}    
