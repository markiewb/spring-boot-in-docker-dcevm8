package com.example.springbootindocker;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

@RestController
public class Controller
{

    @RequestMapping("/")
    public String currentDate()
    {

        return "" + new Date();
    }

}
