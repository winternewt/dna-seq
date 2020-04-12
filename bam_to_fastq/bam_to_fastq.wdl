version development

workflow bam_to_fastq {

    input {
        File bam #750018002018_WGZ.bam
        File? bai #750018002018_WGZ.bam.bai
        Int threads = 16
        String destination
    }

    call samtools_sort {
        input:   bam = bam, threads = threads
    }

    call bam2fastq{
        input: bam = samtools_sort.out, bai = samtools_sort.bai
    }

    call copy {
        input: files = bam2fastq.out,
        destination = destination
    }

    output {
        Array[File] out = copy.out
    }
}

task samtools_sort {
    input {
        File bam
        Int threads
    }

    String name = basename(bam, ".bam")

    command {
       samtools sort -n ~{bam} --threads ~{threads} -o ~{name}_sorted.bam
       samtools index ~{name}_sorted.bam  ~{name}_sorted.bai
    }

    runtime {
        docker: "quay.io/biocontainers/samtools@sha256:70581cfc34eb40cb9b55e49cf5805fce820ec059d7bca9bbb762368ac3c1ac0a" #1.10--h9402c20_2
        maxRetries: 2
      }

    output {
        File out = name + "_sorted.bam"
        File bai = name + "_sorted.bai"
      }
}

task bam2fastq{
    input {
            File bam #750018002018_WGZ.bam
            File? bai #750018002018_WGZ.bam.bai
        }

    command {
        bedtools bamtofastq -i ~{bam} -fq ~{basename(bam)}_1.fq -fq2 ~{basename(bam)}_2.fq
    }

    runtime {
        docker: "quay.io/biocontainers/bedtools@sha256:02e198f8f61329f9eafd1b9fc55828a31020b383403adec22079592b7d868006" #2.29.2--hc088bd4_0
    }

    output {
        Array[File] out = [basename(bam)+"_1.fq", basename(bam)+"_2.fq"]
    }
}

task copy {
    input {
        Array[File] files
        String destination
    }

    String where = sub(destination, ";", "_")

    command {
        mkdir -p ~{where}
        cp -L -R -u ~{sep=' ' files} ~{where}
        declare -a files=(~{sep=' ' files})
        for i in ~{"$"+"{files[@]}"};
          do
              value=$(basename ~{"$"}i)
              echo ~{where}/~{"$"}value
          done
    }

    output {
        Array[File] out = read_lines(stdout())
    }
}