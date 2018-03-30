package com.willshuhua;

import com.willshuhua.demo.ARDS;
import org.python.util.PythonInterpreter;

import java.io.IOException;

public class Main {

    public static void main(String[] args) throws IOException, InterruptedException {
        ARDS ards = new ARDS("hello");
        ards.createProject();
//        PythonInterpreter.initialize(null, null, new String[]{"hello"});
//        PythonInterpreter pythonInterpreter = new PythonInterpreter();
//        pythonInterpreter.exec("print('hello world')");
//        Process process = Runtime.getRuntime().exec("python G:\\Core\\java\\workspace\\Mimic\\res\\python\\hello.py hehe ggg");
//        process.waitFor();
    }
}
