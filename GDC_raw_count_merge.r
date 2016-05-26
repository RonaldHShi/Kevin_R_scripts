GDC_raw_count_merge <- function( id_list="my_id_list", my_rot="no")
    
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
        my_data <- data.matrix(read.table(file=id_list, row.names=1, header=TRUE, sep="\t", comment.char="", quote="", check.names=FALSE))
        my_keys <- unique( rownames(my_data), my_keys )
    }

    # Read second time to generate the metadata matrix
    my_data_matrix <- matrix(NA, length(my_keys), length(my_ids))
    rownames(my_metadata_matrix) <- my_keys
    colnames(my_metadata_matrix) <- my_ids.no_extension
    for ( i in 1:length(my_ids) ){
        print(paste("Second read: ", i))
        my_data <- data.matrix(read.table(file=id_list, row.names=1, header=TRUE, sep="\t", comment.char="", quote="", check.names=FALSE))
        my_data.list <- as.list(my_data)
        names(my_data.list) <- rownames(my_data)
        for ( j in 1:length(my_data.list) ){
            my_data_matrix[ my_keys[j] , my_ids[i] ] <- my_data.list[j]
        }
        rownames(my_metadata_matrix) <- gsub(".htseq.counts.gz", "", rownames(my_metadata_matrix)) # get rid of extensions leaving just the uuid (for easy metadata lookup later) 
    }

    # export the merged data
    if( identical(my_rot, "yes")==TRUE ){
        my_data_matrix <- rot90(rot90(rot90(my_data_matrix)))
    }
    fileout_name <- gsub(" ", "", paste(id_list, ".merged_data.txt"))
    export_data(my_metadata_matrix, fileout_name)
    
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
