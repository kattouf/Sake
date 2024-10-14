# Troubleshooting

If SakeApp is not compiling and you encounter strange errors, you can try clearing its build cache by running the following command:

```bash
sake clean
```

Alternatively, you can manually delete the `.build` directory inside the `SakeApp` directory:

```bash
rm -rf SakeApp/.build
```

After doing this, SakeApp will be rebuilt from scratch the next time you run a command, which can often resolve compilation issues.

### Getting Help and Providing Feedback

If you encounter other problems or have any feature requests, feel free to open an issue on [https://github.com/kattouf/Sake/issues](https://github.com/kattouf/Sake/issues) 
