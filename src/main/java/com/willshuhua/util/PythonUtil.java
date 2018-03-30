package com.willshuhua.util;

import java.io.IOException;

/**
 * python工具，因为部分内容之前使用Python进行计算，因而需调用python进行处理
 */
public class PythonUtil {

    public static void doPython(String fileName, String[] argvs) throws IOException, InterruptedException {
        StringBuilder strLine = new StringBuilder();
        for (String a : argvs){
            strLine.append(" ").append(a);
        }
        System.out.println("python " + fileName + strLine.toString());
        Process process = Runtime.getRuntime().exec("python " + fileName + strLine.toString());
        process.waitFor();
    }
}
